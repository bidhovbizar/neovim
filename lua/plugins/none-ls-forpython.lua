return {
    {
        "nvimtools/none-ls.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local null_ls = require("null-ls")

            null_ls.setup({
                sources = {
                    -- Use Ruff for formatting and linting
                    -- Removed pylint from diagnostics and formatting in lsp.lua file so there is no clash
                    null_ls.builtins.formatting.ruff,
                    null_ls.builtins.diagnostics.ruff,
                    -- Disable ruff for hovering
                    --null_ls.builtins.hover.ruff,
                },
                on_attach = function(client, bufnr)
                    if client.supports_method("textDocument/formatting") then
                        vim.api.nvim_clear_autocmds({ buffer = bufnr, group = nil })
                        vim.api.nvim_create_autocmd("BufWritePre", {
                            buffer = bufnr,
                            callback = function()
                                vim.lsp.buf.format({ bufnr = bufnr })
                            end,
                        })
                    end
                end,
            })
        end,
    }
}
