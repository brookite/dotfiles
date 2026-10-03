#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_FILE="$SCRIPT_DIR/npm_packages.lst"
SEQUENTIAL=false
package_file_set=false

for arg in "$@"; do
  case "$arg" in
    --sequential)
      SEQUENTIAL=true
      ;;
    -*)
      echo "Ошибка: неизвестный параметр: $arg" >&2
      exit 1
      ;;
    *)
      if "$package_file_set"; then
        echo "Использование: $0 [--sequential] [файл_пакетов]" >&2
        exit 1
      fi
      PACKAGE_FILE="$arg"
      package_file_set=true
      ;;
  esac
done

FETCH_TIMEOUT_MS=100000 # 100 seconds; npm expects milliseconds.

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
if "$SEQUENTIAL"; then
  for package in "${packages[@]}"; do
    npm install --global --fetch-timeout="$FETCH_TIMEOUT_MS" "$package"
  done
else
  npm install --global --fetch-timeout="$FETCH_TIMEOUT_MS" "${packages[@]}"
fi
echo "Npm-пакеты установлены."
