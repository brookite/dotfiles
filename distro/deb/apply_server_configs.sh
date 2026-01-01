#!/bin/bash
set -e

USER_HOME=$(eval echo ~${SUDO_USER})
SHARED_DIR="$USER_HOME/shared"

echo "Создаём папку для обмена файлами: $SHARED_DIR"
mkdir -p "$SHARED_DIR"
chown "$SUDO_USER:$SUDO_USER" "$SHARED_DIR"
chmod 770 "$SHARED_DIR"

# Установка Samba
echo "Устанавливаем Samba и vsftpd..."
sudo apt update
sudo apt install -y samba vsftpd gnupg openssh-server

echo "Копируем конфиги..."
sudo cp ../../configs/smb.conf /etc/samba/smb.conf
sudo cp ../../configs/vsftpd.conf /etc/vsftpd.conf

# Перезапуск сервисов
echo "Перезапускаем службы Samba и FTP..."
sudo systemctl restart smbd
sudo systemctl restart vsftpd
sudo systemctl enable smbd
sudo systemctl enable vsftpd

sudo smbpasswd -a $USER

echo "Настройка завершена!"
