termux-setup-storage

pkg upgrade
pkg install tur-repo termux-api termux-services -y
pkg install ncurses-utils curl wget git proot-distro openssl gnupg fakeroot mc openssh lz4 zstd 7zip rsync rclone neovim -y
pkg install -y python rust nodejs-lts openjdk-25 deno golang -y
pkg install -y libzmq libxml2 libxslt -y build-essential cmake fzf binutils binutils-gold cronie dnsutils net-tools inetutils termux-gui-package traceroute ninja -y
python -m pip install --upgrade setuptools wheel
pkg install python-numpy python-pillow python-pandas python-lxml python-scipy python-yt-dlp matplotlib ruff uv leveldb -y

python -m pip install --upgrade -r requirements_termux.txt --extra-index-url https://termux-user-repository.github.io/pypi/