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

-- General
vim.opt.number = true -- Show line numbers
vim.opt.mouse = ''

-- Indentation
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
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
