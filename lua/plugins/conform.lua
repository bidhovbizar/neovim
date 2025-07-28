return {
    "stevearc/conform.nvim",
    lazy = true,
    module = "conform",
    cmd = { "ConformInfor", "ConformToggle", "ConformInfo" },
    opts = {
        formatters_by_ft = {},
    },
    --config = function()
    --    --require("conform").setup({
    --    --formatters_by_ft = {
    --    --	lua = { "stylua" },
    --    --	go = { "goimports", "golines", "gofmt" },
    --    --},
    --    -- format_on_save = {
    --    --     lsp_fallback = true,
    --    --     async = false,
    --    -- },
    --})
}
