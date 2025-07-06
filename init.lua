-- The vim.loader is to ensure fast loading of Neovim plugins
if vim.loader then
    vim.loader.enable()
end

-- Disable Neovim's default Tab mapping for snippets
vim.keymap.del('i', '<Tab>')
vim.keymap.del('s', '<Tab>')

-- Set the runtime path to include the custom plugins directory
require("config.options")
require("core.lazy")
require("core.lsp")
require("config.keymaps")
require("config.autocmds")
