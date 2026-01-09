mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
rm -rf ~/.config/nvim/.git
nvim
# :MasonInstall bash-language-server clangd deno django-template-lsp gopls json-lsp marksman ruff rust-analyzer sqlls stylelint-lsp prettier pyright yaml-language-server typescript-language-server