# Краткое руководство по установке Arch

> Лучше использовать archinstall

1. Правильная разметка разделов
2. Настройка зеркал c помощью <https://archlinux.org/mirrorlist/>
3. Установка пакетов

# Обновление и установка

```bash
pacman -Syu
yay -Syu
```

# Экспорт зависимостей

```bash
pacman -Qqe | grep -vx "$(pacman -Qqg base-devel)" | grep -vx "$(pacman -Qqm)" > archlinux.lst
pacman -Qqm > archlinux_aur.lst
```

# "Осиротевшие" зависимости (аналог `apt autoremove`)

Просмотр:

```bash
pacman -Qdtq
```

Удаление:

```bash
sudo pacman -Rns $(pacman -Qdtq)
```

# Очистка кэша пакетов

```bash
sudo pacman -Sc
```

или агрессивная чистка

```bash
sudo pacman -Scc
paccache -r
```
