-- Adding config.options
require('config.vimoptions')
require('config.keybinds')
require('config.lazy')
vim.lsp.set_log_level("debug") -- Set log level to debug to view trace logs btn nvim and ruff
