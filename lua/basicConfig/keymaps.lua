-- Set the Explorer to using cd
vim.keymap.set("n", "<leader>cd", vim.cmd.Ex)

-- To make <space> not respond to anything else
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Toggle relative numbers
vim.keymap.set('n', '<leader>tr', '<cmd>set relativenumber!<cr>', { desc = "Toggle relative numbers" })
