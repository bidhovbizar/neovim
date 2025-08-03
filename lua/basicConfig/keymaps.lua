-- Set the Explorer to using cd
vim.keymap.set("n", "<leader>cd", vim.cmd.Ex)

-- To make <space> not respond to anything else
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Easier window resizing with arrow keys
vim.keymap.set('n', '<M-Up>', ':resize +2<CR>', { silent = true })
vim.keymap.set('n', '<M-Down>', ':resize -2<CR>', { silent = true })
vim.keymap.set('n', '<M-Left>', ':vertical resize -2<CR>', { silent = true })
vim.keymap.set('n', '<M-Right>', ':vertical resize +2<CR>', { silent = true })

-- Toggle relative numbers
vim.keymap.set('n', '<leader>tr', function()
    vim.opt.relativenumber = not vim.opt.relativenumber:get()
    print("Relative numbers: " .. (vim.opt.relativenumber:get() and "enabled" or "disabled"))
end, { desc = "Toggle relative numbers" })

-- Toggle paste mode with status
vim.keymap.set('n', '<leader>tp', function()
    vim.opt.paste = not vim.opt.paste:get()
    print("Paste mode: " .. (vim.opt.paste:get() and "enabled" or "disabled"))
end, { desc = 'Toggle paste mode' })

-- Toggle list chars with status
vim.keymap.set('n', '<leader>tl', function()
    vim.opt.list = not vim.opt.list:get()
    print("List chars: " .. (vim.opt.list:get() and "enabled" or "disabled"))
end, { desc = 'Toggle list chars' })

-- Toggle word wrap with status
vim.keymap.set('n', '<leader>tw', function()
    vim.opt.wrap = not vim.opt.wrap:get()
    print("Word wrap: " .. (vim.opt.wrap:get() and "enabled" or "disabled"))
end, { desc = 'Toggle word wrap' })
