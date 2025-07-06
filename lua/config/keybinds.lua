-- Set the keybind to space and not \ by default
vim.g.mapleader = " "

-- Set the Explorer to using cd
vim.keymap.set("n", "<leader>cd", vim.cmd.Ex)

-- To make <space> not respond to anything else
-- vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
