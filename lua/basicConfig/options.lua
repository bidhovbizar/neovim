-- Set Neovim options
--
-- Benefits of paste mode
-- 1. Prevents auto-indentation and formatting when pasting code.
-- Issues of using paste mode
-- 1. Disables autoindentation for {}, [] and auto tab
-- 2. Diables copilot accepting suggestions
-- Remember to keep paste mode off always
-- :set paste -- To revert it
-- :set nopaste -- To disable paste mode

-- Python behavior
-- Set Python path explicitly (much faster than auto-detection)
vim.g.python3_host_prog = '/ws/bbizar-bgl/pyenv/shims/python' -- Adjust path as needed

-- General
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'
vim.opt.number = true -- Show line numbers
vim.opt.mouse = ''

-- Indentation
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true

-- Search
vim.opt.ignorecase = true -- Ignore case in search patterns
vim.opt.smartcase = true  -- Override ignorecase if capital letter is used
vim.opt.incsearch = true  -- Show matches as you type
vim.opt.hlsearch = true   -- Highlight search matches

-- Appearance
vim.opt.signcolumn = 'yes' -- Always show the left side ruler and prevents text overflow during diagnostic messages
vim.opt.wrap = true        -- Wrap long lines
vim.opt.scrolloff = 1      -- Set scroll buffer 1 lines top and bottom

-- Split behavior
vim.opt.splitright = true -- Vertical splits to the right
vim.opt.splitbelow = true -- Horizontal splits below

-- Ignore depreciation warnings which will be removed in future versions. Run :checkhealth to see any deprecation warnings.
vim.deprecate = function() end

-- Disable Python providers to speed up startup
vim.g.loaded_python3_provider = 0
vim.g.loaded_python_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

vim.g.have_nerd_font = false
vim.opt.breakindent = true
vim.opt.updatetime = 250 -- Faster updates for CursorHold events, like diagnostics and highlighting
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '␣', nbsp = '⦙', extends = '>', precedes = '<' } --nbsp is non-breaking space
vim.opt.inccommand = 'split'
