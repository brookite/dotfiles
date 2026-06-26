#!/usr/bin/env bash
set -euo pipefail

export NVM_DIR="$HOME/.nvm"

if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
  echo "ERROR: nvm not found at $NVM_DIR/nvm.sh"
  exit 1
fi

# shellcheck source=/dev/null
source "$NVM_DIR/nvm.sh"

echo "Detecting current Node.js version..."

OLD_VERSION="$(nvm current)"

if [[ "$OLD_VERSION" == "none" || -z "$OLD_VERSION" ]]; then
  if nvm use default >/dev/null 2>&1; then
    OLD_VERSION="$(nvm current)"
  else
    OLD_VERSION=""
  fi
fi

if [[ -n "$OLD_VERSION" && "$OLD_VERSION" != "none" ]]; then
  echo "Old/source version: $OLD_VERSION"
  echo
  echo "Global packages in source version:"
  npm ls -g --depth=0 || true
else
  echo "No old/source Node.js version found. Packages will not be migrated."
fi

echo
echo "Installing latest LTS Node.js..."

if [[ -n "$OLD_VERSION" && "$OLD_VERSION" != "none" ]]; then
  nvm install --lts --reinstall-packages-from="$OLD_VERSION"
else
  nvm install --lts
fi

echo
echo "Switching to latest LTS..."

nvm use --lts --delete-prefix
NEW_VERSION="$(nvm current)"

echo
echo "Setting default Node.js version to $NEW_VERSION..."
nvm alias default "$NEW_VERSION"

echo
echo "Removing old Node.js version if it differs from new LTS..."

if [[ -n "$OLD_VERSION" && "$OLD_VERSION" != "none" && "$OLD_VERSION" != "$NEW_VERSION" ]]; then
  echo "Uninstalling old version: $OLD_VERSION"
  nvm uninstall "$OLD_VERSION"
else
  echo "No old version to uninstall, or old version equals new version."
fi

echo
echo "Final check:"
echo "Old version: ${OLD_VERSION:-none}"
echo "New version: $NEW_VERSION"
echo "node: $(command -v node)"
echo "npm:  $(command -v npm)"
echo "node -v: $(node -v)"
echo "npm -v:  $(npm -v)"
echo "npm prefix -g: $(npm prefix -g)"
echo "npm root -g:   $(npm root -g)"

echo
echo "Installed nvm versions:"
nvm ls

echo
echo "Global packages in new LTS:"
npm ls -g --depth=0 || true

echo
echo "Done."
