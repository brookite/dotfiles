#!/bin/bash

# Скрипт для настройки локалей EN и RU в Arch Linux

echo "Добавление локалей en_US.UTF-8 и ru_RU.UTF-8 в /etc/locale.gen..."

# Раскомментируем нужные строки (если закомментированы)
sudo sed -i '/^#en_US.UTF-8 UTF-8/s/^#//' /etc/locale.gen
sudo sed -i '/^#ru_RU.UTF-8 UTF-8/s/^#//' /etc/locale.gen

echo "Генерация локалей..."
sudo locale-gen

echo "Установка основной локали на ru_RU.UTF-8..."

# Запишем основную локаль в /etc/locale.conf
echo "LANG=ru_RU.UTF-8" | sudo tee /etc/locale.conf > /dev/null

# Чтобы сохранить поддержку EN, можно дополнительно установить переменные LC_*
# если это нужно, добавим (по желанию пользователя)
# echo "LC_MESSAGES=en_US.UTF-8" >> /etc/locale.conf

echo "Настройка завершена!"

# Рекомендуется установить правильную локаль в текущей сессии
export LANG=ru_RU.UTF-8

# Проверка, уже ли включен multilib
if grep -Pzo '\[multilib\]\n(?s:.*?\n)*?Include\s*=\s*/etc/pacman\.d/mirrorlist' /etc/pacman.conf | grep -v '^#' &>/dev/null; then
  echo "multilib уже включён."
else
  echo "Включаем multilib..."
  sudo sed -i '/^\s*#\s*\[multilib\]/,/^\s*#\s*Include\s*=.*/ s/^\s*#\s*//' /etc/pacman.conf
  echo "multilib включён."
fi

echo "Обновление списка пакетов..."
sudo pacman -Syu --noconfirm

# Установка зависимостей для компиляции yay
echo "Установка зависимостей для yay..."
sudo pacman -S --needed base-devel git python-pip --noconfirm

# Скачиваем исходники yay из AUR
echo "Клонирование репозитория yay..."
cd /tmp
git clone https://aur.archlinux.org/yay.git

# Переходим в директорию yay
cd yay

# Строим и устанавливаем yay
echo "Сборка и установка yay..."
makepkg -si --noconfirm

# Проверяем установку yay
echo "Проверка установки yay..."
yay --version

echo "yay установлен и готов к использованию!"

# Установка официальных пакетов
echo "Установка пакетов из archlinux.lst..."

# Читаем файл, убираем пустые строки и лишние пробелы
mapfile -t packages < <(grep -v '^\s*$' "archlinux.lst" | sed 's/^\s*//;s/\s*$//' | tr -d '\r')

if [ ${#packages[@]} -eq 0 ]; then
  echo "Файл archlinux.lst пуст или не найден валидных пакетов!"
else
  sudo pacman -S --needed --noconfirm "${packages[@]}"
  echo "Официальные пакеты успешно установлены!"
fi

# Установка AUR пакетов через yay
echo "Установка AUR пакетов из archinstall_aur.lst..."

# Читаем файл, убираем пустые строки и лишние пробелы
mapfile -t aur_packages < <(grep -v '^\s*$' "archlinux_aur.lst" | sed 's/^\s*//;s/\s*$//' | tr -d '\r')

if [ ${#aur_packages[@]} -eq 0 ]; then
  echo "Файл archinstall_aur.lst пуст или не найден валидных пакетов!"
else
  for pkg in ${aur_packages[@]}; do
      echo "Установка пакета: $pkg"
      yay -S --needed --noconfirm "$pkg"
  done
  echo "AUR пакеты успешно установлены!"
fi

echo "Установка всех пакетов завершена успешно!"

echo "Обновление pip, setuptools и wheel..."
python -m pip config set global.break-system-packages true
python -m pip install --upgrade pip setuptools wheel

echo "Установка зависимостей из requirements.txt..."
python -m pip install --user -r requirements.tx" -r apps_python.txt

echo "Установка Python-зависимостей завершена."

echo "Запуск установки через npm..."
bash "npm_install.sh"

sudo ln -sf /usr/bin/nvim /usr/bin/vi
yay --save --answerdiff None --answerclean None --removemake
echo "Все зависимости установлены!"
