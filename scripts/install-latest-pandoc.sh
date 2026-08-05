#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

PANDOC_API_URL="https://api.github.com/repos/jgm/pandoc/releases/latest"

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

log "Установка зависимостей"
"${SUDO[@]}" apt-get update
"${SUDO[@]}" env DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ca-certificates \
    curl \
    jq

arch="$(dpkg --print-architecture)"
case "$arch" in
    amd64|arm64)
        ;;
    *)
        die "официальный deb Pandoc поддерживается этим скриптом только для amd64 и arm64; обнаружено: $arch"
        ;;
esac

log "Определение последнего релиза Pandoc для архитектуры $arch"

release_json="$TMP_DIR/pandoc-release.json"
curl "${CURL_OPTIONS[@]}" \
    -H 'Accept: application/vnd.github+json' \
    "$PANDOC_API_URL" \
    -o "$release_json"

jq -e '.tag_name and (.assets | type == "array")' "$release_json" >/dev/null ||
    die "GitHub API вернул неожиданный ответ"

asset_line="$(
    jq -r --arg arch "$arch" '
        .assets[]
        | select(.name | endswith("-" + $arch + ".deb"))
        | [.name, .browser_download_url, (.digest // "")]
        | @tsv
    ' "$release_json" | head -n 1
)"

[[ -n "$asset_line" ]] ||
    die "в последнем релизе Pandoc не найден deb-пакет для архитектуры $arch"

IFS=$'\t' read -r package_name package_url package_digest <<< "$asset_line"
package_path="$TMP_DIR/$package_name"

log "Скачивание Pandoc: $package_name"
curl "${CURL_OPTIONS[@]}" "$package_url" -o "$package_path"

if [[ "$package_digest" == sha256:* ]]; then
    expected_sha256="${package_digest#sha256:}"
    log "Проверка SHA-256 пакета"
    printf '%s  %s\n' "$expected_sha256" "$package_path" | sha256sum --check -
else
    log "GitHub API не предоставил SHA-256; пакет загружен по HTTPS"
fi

log "Установка Pandoc"
"${SUDO[@]}" apt-get install -y "$package_path"

log "Проверка установленной версии"
pandoc --version | head -n 1

printf '\nУстановка Pandoc завершена.\n'
