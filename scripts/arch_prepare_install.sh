#!/bin/bash

# Скрипт для установки шрифта Terminus с поддержкой кириллицы

set -e

echo "Обновление списка пакетов..."
sudo pacman -Sy archinstall --noconfirm

# Установка шрифта Terminus
echo "Установка шрифта Terminus..."
sudo pacman -S terminus-font --noconfirm

# Установка шрифта DejaVu Sans Mono (если хочешь больше вариантов)
# sudo pacman -S ttf-dejavu --noconfirm

# Установка шрифта Hack (если хочешь попробовать его)
# sudo pacman -S ttf-hack --noconfirm

echo "Шрифт Terminus установлен."

# Настройка терминала для использования шрифта Terminus
echo "Настройка терминала для использования шрифта Terminus..."

# Для консольных терминалов нужно указать в настройках терминала использовать шрифт Terminus.
# В терминале используйте: `setfont ter-116n` для временного изменения шрифта.
# Для постоянного изменения шрифта для tty (консоль), можно отредактировать файл:
echo "setfont ter-v32b" | sudo tee -a /etc/vconsole.conf

echo "Настройка завершена!"

setfont ter-v32b