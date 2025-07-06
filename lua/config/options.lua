-- Set Neovim options

-- Benefits of paste mode
-- 1. Prevents auto-indentation and formatting when pasting code.
-- Issues of using paste mode
-- 1. Disables autoindentation for {}, [] and auto tab
-- 2. Diables copilot accepting suggestions
-- Remember to keep paste mode off always
-- :set paste -- To revert it
-- :set nopaste -- To disable paste mode

-- For ADS server set Python path explicitly (much faster than auto-detection)
--vim.g.python3_host_prog = '/ws/bbizar-bgl/pyenv/shims/python'  -- Adjust path as needed

-- Disable Python providers to speed up startup
vim.g.loaded_python3_provider = 0
vim.g.loaded_python_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

-- General
vim.g.mapleader = ' '
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
vim.opt.signcolumn = 'yes' -- Always show the left side rul
vim.opt.wrap = true        -- Wrap long lines
vim.opt.scrolloff = 1      -- Set scroll buffer 1 lines top and bottom

-- Split behavior
vim.opt.splitright = true -- Vertical splits to the right
vim.opt.splitbelow = true -- Horizontal splits below



--vim.g.maplocalleader = ' '
--vim.g.have_nerd_font = false
--vim.opt.number = true
--vim.opt.mouse = ''
--vim.opt.showmode = false
----vim.schedule(function() vim.opt.clipboard = 'unnamedplus' end)
--vim.opt.breakindent = true
--vim.opt.undofile = true
--vim.opt.ignorecase = true
--vim.opt.smartcase = true
--vim.opt.signcolumn = 'yes'
--vim.opt.updatetime = 250
--vim.opt.timeoutlen = 300
--vim.opt.splitright = true
--vim.opt.splitbelow = true
--vim.opt.list = false
--vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
--vim.opt.inccommand = 'split'
--vim.opt.cursorline = true
--vim.opt.scrolloff = 10
--vim.opt.winborder = "solid" -- https://neovim.io/doc/user/options.html#'winborder'
