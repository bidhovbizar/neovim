-- Set the Explorer to using cd
vim.keymap.set("n", "<leader>cd", vim.cmd.Ex)

-- Set keymap to open :Lazy configuration
vim.keymap.set("n", "<leader>lz", ":Lazy<CR>", { desc = "Open Lazy plugin manager" })

-- To make <space> not respond to anything else
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Easier window resizing with arrow keys
vim.keymap.set('n', '<M-Up>', ':resize +2<CR>', { silent = true })
vim.keymap.set('n', '<M-Down>', ':resize -2<CR>', { silent = true })
vim.keymap.set('n', '<M-Left>', ':vertical resize -2<CR>', { silent = true })
vim.keymap.set('n', '<M-Right>', ':vertical resize +2<CR>', { silent = true })

-- Navigate through buffers (all opened files): We use :bnext or bprev to switch to newly opened files too which :next or :prev doesn't do
vim.keymap.set('n', '<leader>bn', ':bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<leader>bp', ':bprev<CR>', { desc = 'Previous buffer' })

-- Naviagate through all the quickfix list items
vim.keymap.set('n', '<leader>qn', ':cnext<CR>', { desc = 'Next quickfix item' })
vim.keymap.set('n', '<leader>qp', ':cprev<CR>', { desc = 'Previous quickfix item' })
vim.keymap.set('n', '<leader>qN', ':cnfile<CR>', { desc = 'Next file in quickfix' })
vim.keymap.set('n', '<leader>qP', ':cpfile<CR>', { desc = 'Previous file in quickfix' })
vim.keymap.set('n', '<leader>qo', ':copen<CR>', { desc = 'Open quickfix list' })
vim.keymap.set('n', '<leader>qc', ':cclose<CR>', { desc = 'Close quickfix list' })
vim.keymap.set('n', '<leader>ql', ':clist<CR>', { desc = 'Just list quickfix items' })
vim.keymap.set('n', '<leader>qa', ':caddbuffer<CR>', { desc = 'Add buffer to quickfix list' })
vim.keymap.set('n', '<leader>qh', ':chistory<CR>', { desc = 'Show quickfix history' })


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

-- Toggle scrollbind with status
vim.keymap.set('n', '<leader>ts', function()
    vim.wo.scrollbind = not vim.wo.scrollbind
    print("Scrollbind: " .. (vim.wo.scrollbind and "enabled" or "disabled"))
end, { desc = 'Toggle scrollbind for current window' })

-- Set up autocommands and keymaps
local augroup = vim.api.nvim_create_augroup("FormattersGroup", { clear = true })

-- There are 3 ways to format the code
-- 1. Using LSP formatter (if available) using :lua vim.lsp.buf.format() or <leader>lf
-- 2. Using nvim-treesitter default formatter using ==
-- 3. Using external formatters like gofmt, autopep8, shfmt using the command <M-f> as written in this file
--
-- Format files with default tree-sitter formatter.
-- Format Go code using gofmt
local function format_go()
    local view = vim.fn.winsaveview()
    vim.cmd('%!gofmt')
    vim.fn.winrestview(view)
end

vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = "go",
    callback = function()
        vim.keymap.set('n', '<M-f>', format_go, { buffer = true })
    end,
})

-- Format Python code with autopep8. Install using pip install autopep8
local function format_python()
    local view = vim.fn.winsaveview()
    vim.cmd('%!autopep8 --max-line-length=120 --ignore=E129,E265 -')
    vim.fn.winrestview(view)
end

vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = "python",
    callback = function()
        vim.keymap.set('n', '<M-f>', format_python, { buffer = true })
    end,
})

-- Format Shell scripts with shfmt install using sudo apt install shfmt
local function format_shell()
    local view = vim.fn.winsaveview()
    vim.cmd('%!shfmt')
    vim.fn.winrestview(view)
end

vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = "sh",
    callback = function()
        vim.keymap.set('n', '<M-f>', format_shell, { buffer = true })
    end,
})
