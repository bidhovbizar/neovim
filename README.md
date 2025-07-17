The Neovim Config using here is from the video:
How To Configure LSP Natively (neovim v0.11+) - https://youtu.be/IZnhl121yo0
# Neovim main branch with latest changes
Copy paste the following in ~/.config/nvim/(all the files except git)<br>
The configuration for neovim<br>
The config base is taken from: Neovim Config using here: https://youtu.be/IZnhl121yo0<br>
<br>
The branch is for neovim-v0.11 which I build using tools and have it in my Ubuntu24 and ADS server. <br>
The features added are<br>
lua/plugin:<br>
blink.lua -> Autocompletion handled here<br>
colorsandlualine.lua -> extra colourful bottom line and setting colours for CSS<br>
conform.lua -> Don't remember<br>
copilot.lua -> Basic copilot addition<br>
copilotchat.lua -> Copilot support chat with neovim<br>
gitandcsscolor.lua -> Adding git support and adding css color<br>
harpoon.lua -> Harpoon tool for chosing special files<br>
lazydev.lua -> Don't remember<br>
telescope.lua -> Help in live grep, live search of files and other greping<br>
treesitter.lua -> Help in function movement<br>
vim-sleuth.lua -> Don't know<br>
<br>
lua/core<br>
lazy.lua -> Don't know<br>
lsp.lua -> language server processor(LSP) which will trigger dedicated LSP for each language and help in autocomeplete and help<br>
<br>
lua/config<br>
keymaps.lua -> Shortcuts for all keys<br>
options.lua -> VIM options needed<br>
autocmds.lua -> Autocommand functions such as when we save<br>
