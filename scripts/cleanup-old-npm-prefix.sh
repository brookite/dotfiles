#!/usr/bin/env bash
set -euo pipefail

echo "Current npm prefix:"
PREFIX="$(npm prefix -g)"
ROOT="$(npm root -g)"
BIN_DIR="$PREFIX/bin"

echo "PREFIX = $PREFIX"
echo "ROOT   = $ROOT"
echo "BIN    = $BIN_DIR"
echo

if [[ ! -d "$ROOT" ]]; then
  echo "Global npm root does not exist: $ROOT"
else
  echo "Collecting globally installed packages..."

  mapfile -t PACKAGES < <(
    find "$ROOT" -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
      base="$(basename "$dir")"

      if [[ "$base" == @* ]]; then
        find "$dir" -mindepth 1 -maxdepth 1 -type d | while read -r scoped_pkg; do
          echo "$base/$(basename "$scoped_pkg")"
        done
      else
        echo "$base"
      fi
    done | sort
  )

  if [[ "${#PACKAGES[@]}" -eq 0 ]]; then
    echo "No global packages found."
  else
    echo "Packages to remove:"
    printf '  %s\n' "${PACKAGES[@]}"
    echo

    echo "Uninstalling global packages..."
    npm uninstall -g "${PACKAGES[@]}"
  fi
fi

echo
echo "Removing dangling npm symlinks from $BIN_DIR if they point to old global node_modules..."

if [[ -d "$BIN_DIR" ]]; then
  find "$BIN_DIR" -type l | while read -r link; do
    target="$(readlink -f "$link" || true)"

    if [[ -z "$target" || "$target" == "$ROOT"* ]]; then
      echo "Removing symlink: $link -> $target"
      rm -f "$link"
    fi
  done
fi

echo
echo "Deleting npm prefix/globalconfig settings..."
npm config delete prefix || true
npm config delete globalconfig || true

if [[ -f "$HOME/.npmrc" ]]; then
  sed -i '/^prefix[[:space:]]*=/d;/^globalconfig[[:space:]]*=/d' "$HOME/.npmrc"
fi

echo
echo "Loading nvm if available..."

export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  # shellcheck source=/dev/null
  source "$NVM_DIR/nvm.sh"

  NODE_VERSION="$(node -v)"
  echo "Running: nvm use --delete-prefix $NODE_VERSION --silent"
  nvm use --delete-prefix "$NODE_VERSION" --silent
else
  echo "nvm.sh not found at $NVM_DIR/nvm.sh; skipping nvm use."
fi

echo
echo "Final check:"
echo "node: $(command -v node || true)"
echo "npm:  $(command -v npm || true)"
echo "npm prefix -g: $(npm prefix -g)"
echo "npm root -g:   $(npm root -g)"
echo
echo "Done."
