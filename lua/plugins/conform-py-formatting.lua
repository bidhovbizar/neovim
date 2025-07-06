return {
    "stevearc/conform.nvim",
    opts = {
        formatters_by_ft = {
            python = {
                "ruff_fix",
                "ruff_format",
                "ruff_organize_imports",
            },
        },
        format_on_save = {
            lsp_fallback = true,
            timeout_ms = 1000,
        }
    },
}
