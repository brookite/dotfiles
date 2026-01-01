has_gui() {
  # Windows (Git Bash / MSYS / MINGW)
  case "$OSTYPE" in
    msys*|mingw*|cygwin*)
      return 0
      ;;
  esac

  if [ -n "$WSL_DISTRO_NAME" ] || [ -n "$WSL_INTEROP" ]; then
    return 1
  fi

  # Unix-like: X11 или Wayland
  [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]
}

uv self update
uv tool upgrade ty
python3.14 -m pip install --upgrade pip setuptools wheel
if has_gui; then
  python3.14 -m pip install --upgrade -r requirements.txt -r apps_python.txt
else
  python3.14 -m pip install --upgrade -r requirements_console.txt
fi
