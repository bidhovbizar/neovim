return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "InsertLeave" }, -- lazy-load on relevant events
    config = function()
        local lint = require("lint")

        lint.linters_by_ft = {
            python = { "ruff" },
        }

        -- Automatically trigger linting
        vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
            callback = function()
                lint.try_lint()
            end,
        })
    end,
}
