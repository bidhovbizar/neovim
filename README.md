# Readme for the configuration setuped for neovim
The Neovim Config using here is from the video:
How To Configure LSP Natively (neovim v0.11+) - https://youtu.be/IZnhl121yo0
## Neovim main branch with latest changes
Copy paste the following in ~/.config/nvim/(all the files except git)<br>
The configuration for neovim<br>
The config base is taken from: Neovim Config using here: https://youtu.be/IZnhl121yo0<br>
<br>

There are 3 branches these are there relevance:<br>
1. main -> This is the latest branch with all the latest changes with latest neovim<br>
2. neovim-v0.11 -> This is the branch for neovim version v0.11<br>
3. neovim-v0.95 -> This is the branch for neovim v0.95<br>
Note: The branch is for neovim-v0.11 which I build using tools and have it in my Ubuntu24 and ADS server. <br>
<br>

## The features added are:<br>

lua/basicConfig<br>
autocmds4highlight.lua -> Autocommand functions such as when we save<br>
keymaps.lua -> Shortcuts for all keys<br>
options.lua -> VIM options needed<br>
<br>

lua/core<br>
lazy.lua -> Initializes lazy plugin manager know<br>
lsp.lua -> language server processor(LSP) which will trigger dedicated LSP for each language and help in autocomeplete and help<br>
<br>

lua/lsp<br>
basedpyright.lua -> Basedpyright for python language server settings<br>
bash.lua -> Bash language server settings<br>
gopls.lua -> Go language server settings<br>
lua_ls.lua -> Lua language server settings<br>
pyright.lua -> Pyright for python language server settings<br>
yamlls.lua -> YAML language server settings<br>
<br>

lua/plugin:<br>
avante.lua -> Avante for agent mode of copilot<br>
blink.lua -> Autocompletion handled here<br>
colorsandlualine.lua -> extra colourful bottom line and setting colours for CSS<br>
conform.lua -> Don't remember<br>
copilot.lua -> Basic copilot addition<br>
copilotchat.lua -> Copilot support chat with neovim<br>
git.lua -> Adds vim-fugitive, diffview and git-conflicts<br>
harpoon.lua -> Harpoon tool for chosing special files<br>
lazydev.lua -> Don't remember<br>
outline.lua -> Help in outline of functions and variables<br>
snacks.lua -> Helps in only file explorer other functions are disabled<br>
telescope.lua -> Help in live grep, live search of files and other greping<br>
treesitter.lua -> Help in function movement<br>
undotree.lua -> Helps in constructing undoing changes tree<br>
<br>

lua/prompts:<br>
copilotprompts.lua -> Prompts for copilot<br>


### LSP
lsp.lua file is the main file which will trigger the LSP for each language. Its situated in ~/.config/nvim/lua/core/lsp.lua<br>
Read the comments of the lsp.lua file to understand how it works and uncomment accordingly.<br>
If you don't need the diagnostic, then comment the section in the lsp.lua file and continue.<br>
The diagnostic keymapping also reside in the same file, so you can use them. I have configured the nvim for python and golang without debugger.<br>
The settings for go, python and lua is at ~/.config/nvim/lua/lsp. Files inside the folder is used as require(lsp.<filename>) in the lsp.lua file to configure.<br>

## Installation for just autocompletion and not formating
Go: Ensure go path in in $PATH
==============================
Go: Install from direct website for ubuntu untar and copy to the ~/.local/share/<br>
gopls: Install from another website <br>

Python
======
pyright: Old slow but contains everything - pip install pyright<br>
basedpyright: Faster but doesn't contain everything - pip install basedpyright<br>

lua
===
You would find the lua-language-server tar file from github. You can copy it to the right place and add it to the path <br>

Bash
====
bash-language-server: Install from npm - npm install -g bash-language-server<br>
For shellcheck, you can install it from apt - sudo apt install shellcheck<br> if you have sudo access or in ubuntu. But for RHEL you can install it from the website and copy it to the right place.<br> or you can use the shellcheck from npm - npm install -g shellcheck<br> 
