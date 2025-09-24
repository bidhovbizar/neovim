return {
    {
        "folke/lazydev.nvim",
        --event = "VeryLazy", -- Load later, not on filetype. But don't uncomment this as it will load even if not needed
        ft = "lua", -- only load on lua files,
        opts = {
            library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    }
}
