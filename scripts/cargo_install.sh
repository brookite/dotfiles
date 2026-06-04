#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_FILE="${1:-"$SCRIPT_DIR/cargo-packages.lst"}"

if ! command -v cargo >/dev/null 2>&1; then
  echo "Ошибка: cargo не найден в PATH." >&2
  exit 1
fi

if ! command -v cargo-binstall >/dev/null 2>&1; then
  echo "Ошибка: cargo-binstall не найден в PATH. Установите его заранее." >&2
  exit 1
fi

if [[ ! -f "$PACKAGE_FILE" ]]; then
  echo "Ошибка: файл со списком пакетов не найден: $PACKAGE_FILE" >&2
  exit 1
fi

packages=()
while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%%#*}"
  line="${line#"${line%%[![:space:]]*}"}"
  line="${line%"${line##*[![:space:]]}"}"

  [[ -z "$line" ]] && continue
  packages+=("$line")
done < "$PACKAGE_FILE"

if (( ${#packages[@]} == 0 )); then
  echo "В файле $PACKAGE_FILE нет пакетов для установки."
  exit 0
fi

echo "Установка cargo-пакетов из $PACKAGE_FILE через cargo binstall..."
cargo binstall -y "${packages[@]}"
echo "Cargo-пакеты установлены."
