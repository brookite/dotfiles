#!/usr/bin/env bash
set -euo pipefail

prefix=${1:-/usr/local}
pyver=${2:-3.13}

echo ">>> Uninstalling Python ${pyver} from prefix: ${prefix}"
python_bin="${prefix}/bin/python${pyver}"

# --- Step 1. Удалить все пакеты pip, установленные этим Python ---
if [ -x "$python_bin" ]; then
    echo ">>> Uninstalling all user-installed pip packages for Python ${pyver}..."
    "$python_bin" -m pip freeze --user | xargs -r "$python_bin" -m pip uninstall -y || true
else
    echo ">>> Warning: Python binary ${python_bin} not found. Skipping pip uninstall."
fi

# --- Step 2. Удалить каталог с модулями в ~/.local (если остался) ---
user_lib="$HOME/.local/lib/python${pyver}"
if [ -d "$user_lib" ]; then
    echo ">>> Removing leftover user library: $user_lib"
    rm -rf "$user_lib"
fi

# --- Step 3. Удалить известные файлы altinstall ---
echo ">>> Removing core files from prefix..."
rm -rf \
    "${prefix}/bin/python${pyver}" \
    "${prefix}/bin/python${pyver}m" \
    "${prefix}/bin/pip${pyver}" \
    "${prefix}/bin/pip${pyver}m" \
    "${prefix}/bin/idle${pyver}" \
    "${prefix}/bin/pydoc${pyver}" \
    "${prefix}/bin/2to3-${pyver}" \
    "${prefix}/bin/pyvenv-${pyver}" \
    "${prefix}/bin/python${pyver}-config" \
    "${prefix}/bin/python${pyver}m-config" \
    "${prefix}/lib/libpython${pyver}.a" \
    "${prefix}/lib/libpython${pyver}m.a" \
    "${prefix}/lib/python${pyver}" \
    "${prefix}/include/python${pyver}" \
    "${prefix}/include/python${pyver}m" \
    "${prefix}/lib/pkgconfig/python-${pyver}.pc" \
    "${prefix}/share/man/man1/python${pyver}.1" || true

echo ">>> Python ${pyver} removed."

# --- Step 4. Проверка остаточных бинарников в ~/.local/bin ---
local_bin="$HOME/.local/bin"
if [ -d "$local_bin" ]; then
    echo ">>> Checking for leftover Python executables in ${local_bin}..."
    find "$local_bin" -type f -executable -maxdepth 1 \
        -exec grep -Il "python${pyver}" {} \; | while read -r f; do
            echo "Removing Python-related script: $f"
            rm -f "$f"
        done
fi

echo ">>> Done."
