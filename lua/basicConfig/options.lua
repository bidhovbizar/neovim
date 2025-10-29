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

-- Disable Python providers early to speed up startup
vim.g.loaded_python3_provider = 0
vim.g.loaded_python_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

-- Python behavior
-- Set Python path explicitly (much faster than auto-detection)
vim.g.python3_host_prog = '/ws/bbizar-bgl/pyenv/shims/python' -- Adjust path as needed

-- General
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'
vim.opt.number = true -- Show line numbers
vim.opt.mouse = ''

-- Indentation
vim.opt.relativenumber = false
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

vim.g.have_nerd_font = false
vim.opt.breakindent = true
vim.opt.updatetime = 250 -- Faster updates for CursorHold events, like diagnostics and highlighting
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '␣', nbsp = '⦙', extends = '>', precedes = '<' } --nbsp is non-breaking space
vim.opt.inccommand = 'split'

vim.g.netrw_liststyle = 1 -- 3: Use tree view by default, 1: Shows folder view with size and time
vim.g.netrw_banner = 1 -- Show the banner at the top
vim.g.netrw_winsize = 75 -- Set width of the newly opened window (in percentage)
vim.g.netrw_altv = 1 -- Open files in vertical split to the right when you press v and not <CR>

-- Open files in vertical split to the right under <CR>(not in netrw split)
-- vim.g.netrw_browse_split = 2
