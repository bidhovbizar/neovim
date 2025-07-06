-- Setting up formatter for python using ruff only and no pyright. I ensured
return {
    "stevearc/conform.nvim",
    main = "conform",
    opts = {
        formatters_by_ft = {
            python = {
                "ruff_fix",
                "ruff_format",
                "ruff_organize_imports",
            },
        },
        format_on_save = false
    },
    keys = {
        { "<M-f>", function() require("conform").format({ async = true, lsp_fallback = true }) end, desc = "Format buffer" },
    },
}
