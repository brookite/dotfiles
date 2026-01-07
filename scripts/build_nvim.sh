# Neovim сборка
echo "Сборка и установка Neovim..."
git clone --branch stable --depth 1 https://github.com/neovim/neovim ~/neovim
cd ~/neovim
make CMAKE_BUILD_TYPE=Release
cd build
cpack -G DEB
DEB_PKG=$(find . -maxdepth 1 -name "nvim-*.deb" | head -n1)
mv "$DEB_PKG" nvim-linux64.deb
sudo dpkg -i nvim-linux64.deb
cd ../../
sudo rm -rf neovim
