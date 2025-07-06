-- Only enable LSPs when the appropriate filetype is detected
-- Using group variable to group all the lsp together in nvim_create_autocmd this ensure no duplicate call
local group = vim.api.nvim_create_augroup("LSPFileType", { clear = true })

-- Go
vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    group = group,
    callback = function()
        vim.lsp.enable("gopls")
    end,
})

-- Lua
vim.api.nvim_create_autocmd("FileType", {
    pattern = "lua", 
    group = group,
    callback = function()
        vim.lsp.enable("lua_ls")
    end,
})

--vim.lsp.enable({
--    "gopls",
--    "lua_ls"
--})

vim.diagnostic.config({
    virtual_lines = true,
    --virtual_text = true,
    underline = true,
     update_in_insert = false,
    severity_sort = true,
    float = {
        border = "rounded",
        source = true,
    },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
        numhl = {
            [vim.diagnostic.severity.ERROR] = "ErrorMsg",
            [vim.diagnostic.severity.WARN] = "WarningMsg",
        },
    },
})
