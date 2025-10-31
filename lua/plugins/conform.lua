-- This file is used to manage external formatters in Neovim using the conform.nvim plugin.
return {
    "stevearc/conform.nvim",
    lazy = true,
    module = "conform",
    cmd = { "ConformInfo" },
    opts = {},
    config = function()
        require("conform").setup({
            formatters_by_ft = {
                -- Install stylua sudo apt install cargo; cargo install stylua
                --lua = { "stylua" },

                --go = { "goimports", "golines", "gofmt" },
            },
            -- Fomat_on_save is disabled by default, you can enable it if you want
            --format_on_save = {
            --    lsp_fallback = true,
            --    async = true,
            --},
        })
    end,
    keys = {
        -- This is disabled as I am using nvim treesitter formatter and lsp formatter
        -- The same command is used for running
        --{ "<M-f>", function() require("conform").format({ async = true, lsp_fallback = true }) end, mode = "n", desc = "Format buffer" },
    }
}
