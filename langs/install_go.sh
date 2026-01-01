#!/bin/bash

set -e  # Остановиться при ошибке

echo "Определение последней версии Go..."
GO_LATEST=$(curl -s https://go.dev/VERSION?m=text | head -n 1)
echo "Последняя версия: $GO_LATEST"

# Определяем архитектуру
ARCH="$(uname -m)"
case "$ARCH" in
    x86_64) ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
    armv6l|armv7l) ARCH="armv6l" ;;  # Go для ARMv6 (подходит для armhf)
    *) echo "Неизвестная архитектура: $ARCH" && exit 1 ;;
esac

# Формируем имя архива
GO_ARCHIVE="${GO_LATEST}.linux-${ARCH}.tar.gz"
DOWNLOAD_URL="https://go.dev/dl/${GO_ARCHIVE}"

echo "⬇️ Скачивание $GO_ARCHIVE..."
curl -O -L "$DOWNLOAD_URL"

# Удаляем старую версию Go
echo "Удаление старой версии Go из /usr/local/go..."
sudo rm -rf /usr/local/go || true

# Распаковка архива
echo "Установка новой версии Go..."
sudo tar -C /usr/local -xzf "$GO_ARCHIVE"

# Удаляем архив
rm "$GO_ARCHIVE"

# Проверка версии
echo "Go успешно установлен в /usr/local/go/bin! Текущая версия:"
export PATH=$PATH:/usr/local/go/bin
go version
