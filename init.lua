-- The vim.loader is to ensure fast loading of Neovim plugins
if vim.loader then
    vim.loader.enable()
end

-- Disable Neovim's default Tab mapping for snippets
pcall(vim.keymap.del, 'i', '<Tab>')
pcall(vim.keymap.del, 's', '<Tab>')

-- Set the runtime path to include the custom plugins directory
require("basicConfig.options")
require("basicConfig.keymaps")
require("basicConfig.autocmds4highlight")
require('basicConfig.netrwhelp')
require("core.lazy")
require("core.lsp")
