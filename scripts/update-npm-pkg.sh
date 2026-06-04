#!/usr/bin/env bash

set -u

echo "Checking global npm packages..."

json="$(npm outdated -g --json 2>/dev/null || true)"

if [[ -z "$json" || "$json" == "{}" ]]; then
  echo "All global npm packages are up to date."
  exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required for this script."
  echo "Install it first:"
  echo "  sudo apt install jq"
  echo "or:"
  echo "  pacman -S jq"
  exit 1
fi

package_names="$(echo "$json" | jq -r 'keys[]')"

if [[ -z "$package_names" ]]; then
  echo "All global npm packages are up to date."
  exit 0
fi

echo
echo "Outdated global packages:"
echo

printf "%-35s %-15s %-15s %-15s\n" "Package" "Current" "Wanted" "Latest"
printf "%-35s %-15s %-15s %-15s\n" "-------" "-------" "------" "------"

echo "$json" | jq -r '
  to_entries[]
  | [
      .key,
      .value.current,
      .value.wanted,
      .value.latest
    ]
  | @tsv
' | while IFS=$'\t' read -r name current wanted latest; do
  printf "%-35s %-15s %-15s %-15s\n" "$name" "$current" "$wanted" "$latest"
done

echo
read -r -p "Update all packages to latest versions? (y/N): " answer

case "$answer" in
  y|Y|yes|YES|д|Д|да|ДА)
    ;;
  *)
    echo "Update cancelled."
    exit 0
    ;;
esac

echo
echo "Updating packages..."

while IFS= read -r package; do
  echo
  echo "Updating $package to latest..."

  if npm install -g "$package@latest"; then
    echo "Updated $package"
  else
    echo "Failed to update $package" >&2
  fi
done <<< "$package_names"

echo
echo "Done."
