#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# Параметры можно переопределить:
#   PREFIX=/opt/git JOBS=4 RUN_TESTS=1 ./install-latest-git.sh
PREFIX="${PREFIX:-/usr/local}"
JOBS="${JOBS:-$(nproc 2>/dev/null || printf '1')}"
RUN_TESTS="${RUN_TESTS:-0}"

GIT_BASE_URL="https://www.kernel.org/pub/software/scm/git"

log() {
    printf '\n==> %s\n' "$*"
}

die() {
    printf 'Ошибка: %s\n' "$*" >&2
    exit 1
}

if [[ "${EUID}" -eq 0 ]]; then
    SUDO=()
elif command -v sudo >/dev/null 2>&1; then
    SUDO=(sudo)
else
    die "запустите скрипт от root или установите sudo"
fi

command -v apt-get >/dev/null 2>&1 ||
    die "скрипт предназначен для Debian/Ubuntu и других систем с apt-get"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

CURL_OPTIONS=(
    --proto '=https'
    --tlsv1.2
    --fail
    --location
    --silent
    --show-error
    --retry 3
    --retry-delay 2
)

log "Установка зависимостей для сборки Git"
"${SUDO[@]}" apt-get update
"${SUDO[@]}" env DEBIAN_FRONTEND=noninteractive apt-get install -y \
    autoconf \
    build-essential \
    ca-certificates \
    curl \
    gettext \
    libcurl4-openssl-dev \
    libexpat1-dev \
    libpcre2-dev \
    libssl-dev \
    perl \
    xz-utils \
    zlib1g-dev

log "Определение последней стабильной версии Git"

index_path="$TMP_DIR/git-index.html"
curl "${CURL_OPTIONS[@]}" "$GIT_BASE_URL/" -o "$index_path"

version="$(
    sed -nE \
        's/.*href="git-([0-9]+\.[0-9]+\.[0-9]+)\.tar\.xz".*/\1/p' \
        "$index_path" |
    sort -V |
    tail -n 1
)"

[[ -n "$version" ]] ||
    die "не удалось определить последнюю стабильную версию Git"

source_name="git-$version.tar.xz"
source_url="$GIT_BASE_URL/$source_name"
source_path="$TMP_DIR/$source_name"
source_dir="$TMP_DIR/git-$version"

log "Скачивание исходников Git $version"
curl "${CURL_OPTIONS[@]}" "$source_url" -o "$source_path"

log "Распаковка исходников"
tar -xJf "$source_path" -C "$TMP_DIR"

[[ -d "$source_dir" ]] ||
    die "после распаковки не найден каталог $source_dir"

log "Конфигурация Git с префиксом $PREFIX"
(
    cd "$source_dir"

    make configure
    ./configure --prefix="$PREFIX"

    log "Сборка Git с использованием $JOBS потоков"
    make -j"$JOBS" all

    if [[ "$RUN_TESTS" == "1" ]]; then
        log "Запуск тестов Git"
        make -j"$JOBS" test
    fi

    log "Установка Git в $PREFIX"
    "${SUDO[@]}" make install
)

manpages_name="git-manpages-$version.tar.xz"
manpages_url="$GIT_BASE_URL/$manpages_name"
manpages_path="$TMP_DIR/$manpages_name"

if curl "${CURL_OPTIONS[@]}" --head "$manpages_url" >/dev/null; then
    log "Установка man-страниц Git"
    curl "${CURL_OPTIONS[@]}" "$manpages_url" -o "$manpages_path"
    "${SUDO[@]}" mkdir -p "$PREFIX/share/man"
    "${SUDO[@]}" tar -xJf "$manpages_path" -C "$PREFIX/share/man"
else
    log "Архив man-страниц Git $version не найден; пропускаю"
fi

hash -r 2>/dev/null || true

log "Проверка установленной версии"
if [[ -x "$PREFIX/bin/git" ]]; then
    "$PREFIX/bin/git" --version
else
    die "Git не найден по ожидаемому пути: $PREFIX/bin/git"
fi

printf '\nПуть к Git: %s/bin/git\n' "$PREFIX"
printf 'Текущий git в PATH: %s\n' "$(command -v git || true)"
printf '\nУстановка Git завершена.\n'
