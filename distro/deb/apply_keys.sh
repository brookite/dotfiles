# 🗝️ Перенос ключей
echo "Переносим ключи..."

# SSH ключи
if compgen -G "../../keys/*.ssh.pub" > /dev/null; then
  echo "Устанавливаем публичные SSH ключи..."
  mkdir -p "$USER_HOME/.ssh"
  cat ../../keys/*.ssh.pub >> "$USER_HOME/.ssh/authorized_keys"
  chown -R "$SUDO_USER:$SUDO_USER" "$USER_HOME/.ssh"
  chmod 700 "$USER_HOME/.ssh"
  chmod 600 "$USER_HOME/.ssh/authorized_keys"
fi

if compgen -G "../../keys/*.ssh.key" > /dev/null; then
  echo "Переносим приватные SSH ключи..."
  for key in ../../keys/*.ssh.key; do
    cp "$key" "$USER_HOME/.ssh/"
    chmod 600 "$USER_HOME/.ssh/$(basename "$key")"
  done
fi

# GPG ключи
if compgen -G "../../keys/*.gpg.pub" > /dev/null; then
  echo "Импортируем публичные GPG ключи..."
  for key in ../../keys/*.gpg.pub; do
    sudo -u "$SUDO_USER" gpg --import "$key"
  done
fi

if compgen -G "../../keys/*.gpg.key" > /dev/null; then
  echo "Импортируем приватные GPG ключи..."
  for key in ../../keys/*.gpg.key; do
    sudo -u "$SUDO_USER" gpg --import "$key"
  done
fi