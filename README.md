# neovim
The configuration for neovim
The config base is taken from: Neovim Config using here: https://youtu.be/IZnhl121yo0

The branch is for neovim-v0.11 which I build using tools and have it in my Ubuntu24 and ADS server. 
The features added are
lua/plugin:
blink.lua -> Autocompletion handled here
colorsandlualine.lua -> extra colourful bottom line and setting colours for CSS
conform.lua -> Don't remember
copilot.lua -> Basic copilot addition
copilotchat.lua -> Copilot support chat with neovim
gitandcsscolor.lua -> Adding git support and adding css color
harpoon.lua -> Harpoon tool for chosing special files
lazydev.lua -> Don't remember
telescope.lua -> Help in live grep, live search of files and other greping
treesitter.lua -> Help in function movement
vim-sleuth.lua -> Don't know

lua/core
lazy.lua -> Don't know
lsp.lua -> language server processor(LSP) which will trigger dedicated LSP for each language and help in autocomeplete and help

lua/config
keymaps.lua -> Shortcuts for all keys
options.lua -> VIM options needed
autocmds.lua -> Autocommand functions such as when we save
