--vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
--vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
--vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
--
--vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
--vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
--vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
--vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
--
--vim.keymap.set('n', '<leader>e', ':Ex<cr>', { desc = 'Open [E]xplorer' })

-- Set the keybind to space and not \ by default
-- vim.g.mapleader = " "

-- Set the Explorer to using cd
vim.keymap.set("n", "<leader>cd", vim.cmd.Ex)

-- To make <space> not respond to anything else
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Show diagnostics in a floating window
-- It runs: :lua vim.diagnostic.open_float()
vim.keymap.set("n", "<leader>/", vim.diagnostic.open_float)

-- Toggle relative numbers
vim.keymap.set('n', '<leader>tr', '<cmd>set relativenumber!<cr>', { desc = "Toggle relative numbers" })

-- Setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
--vim.g.mapleader = " "
--vim.g.maplocalleader = "\\"  -- Help to setup leader key for special fileType
