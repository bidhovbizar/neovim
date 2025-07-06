-- Set the keybind to space and not \ by default
vim.g.mapleader = " "

-- Set the Explorer to using cd
vim.keymap.set("n", "<leader>cd", vim.cmd.Ex)

-- To make <space> not respond to anything else
-- vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
--
-- Setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
--vim.g.mapleader = " "
--vim.g.maplocalleader = "\\"  -- Help to setup leader key for special fileType
