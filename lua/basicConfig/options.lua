-- Set Neovim options
--
-- Benefits of paste mode
-- 1. Prevents auto-indentation and formatting when pasting code.
-- Issues of using paste mode
-- 1. Disables autoindentation for {}, [] and auto tab
-- 2. Diables copilot accepting suggestions
-- Remember to keep paste mode off always
-- To toggle paste mode, use <leader>tp
-- :set paste -- To revert it
-- :set nopaste -- To disable paste mode
--
-- Benefits of scrollbind
-- 1. Allows you to scroll multiple windows simultaneously, which is useful for comparing files side by side.
-- To toggle scrollbind, use <leader>ts

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
-- To toggle relativenumber, use <leader>tr
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
-- To toggle word wrap, use <leader>tw
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
-- To toggle listchars, use <leader>tl
vim.opt.listchars = { tab = '» ', trail = '␣', nbsp = '⦙', extends = '>', precedes = '<' } --nbsp is non-breaking space
vim.opt.inccommand = 'split'

vim.g.netrw_liststyle = 1 -- 3: Use tree view by default, 1: Shows folder view with size and time
vim.g.netrw_banner = 1    -- Show the banner at the top
vim.g.netrw_winsize = 75  -- Set width of the newly opened window (in percentage)
vim.g.netrw_altv = 1      -- Open files in vertical split to the right when you press v and not <CR>

-- Neovim commandline gives options to complete when pressed <Tab>
vim.opt.wildmode = 'longest:full,full'
vim.opt.wildoptions = 'pum'

-- Open files in vertical split to the right under <CR>(not in netrw split)
-- vim.g.netrw_browse_split = 2

-- Limit the number of oldfiles stored to 100 and 
-- the size of each file to 50KB, and 
-- store up to 10 search patterns.
-- The 'h' flag prevents storing command-line history.
-- vim.o.shada = "!,'100,<50,s10,h"  -- default value
--vim.o.shada = table.concat({
--    "'50",   -- Remember marks for 50 files (reduces oldfiles)
--    "<50",   -- Max 50 lines per register
--    "s10",   -- Skip registers > 10KB
--    "h",     -- No hlsearch on load
--    ":100",  -- 100 command-line history
--    "/50",   -- 50 search patterns
--    "r/tmp", -- Ignore /tmp files
--    "r/mnt", -- Ignore mounted drives
--}, ",")
