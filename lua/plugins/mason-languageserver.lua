return {
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        build = ":MasonUpdate",
        config = function()
            require("mason").setup()
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require("mason-lspconfig").setup({
                -- To uninstall any added language servers ensure the following:
                -- 1. Remove the server from the list below.
                -- 2. Run :MasonUninstall <server_name> e.g. :MasonUninstall pyright
                ensure_installed = { -- This installs lua-language-server automatically
                    "lua_ls",
                    "ruff",
                    "pyright"
                },
                automatic_installation = true,
            })
        end,
    },
}
