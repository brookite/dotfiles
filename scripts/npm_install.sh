#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_FILE="${1:-"$SCRIPT_DIR/npm_packages.lst"}"
FETCH_TIMEOUT_MS=300000 # 300 seconds; npm expects milliseconds.

if ! command -v npm >/dev/null 2>&1; then
  echo "Ошибка: npm не найден в PATH." >&2
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

echo "Установка npm-пакетов из $PACKAGE_FILE..."
npm install --global --fetch-timeout="$FETCH_TIMEOUT_MS" "${packages[@]}"
echo "Npm-пакеты установлены."
