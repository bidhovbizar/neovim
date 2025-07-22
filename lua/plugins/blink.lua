return {
    { "L3MON4D3/LuaSnip",
        event = "InsertEnter",
    },
        {
        "saghen/blink.cmp",
        event = "InsertEnter",
        dependencies = {
            "rafamadriz/friendly-snippets",
        },
        version = "*",
        config = function()
            require("blink.cmp").setup({
                snippets = { preset = "luasnip" },
                -- If an LSP server is running then signature will help you with the commands inside it
                signature = { enabled = true },
                -- If you have installed nerd-fonts in windows then you can use it to display icons else ignore this
                --appearance = {
                --    use_nvim_cmp_as_default = false,
                --    nerd_font_variant = "normal",
                --},
                sources = {
                    -- If you want lsp to be the first source then you can use this
                    default = { "lsp", "path", "snippets", "buffer" },
                    -- If you don't want lsp but all the other features then go with this
                    --default = { "path", "snippets", "buffer" },
                    providers = {
                        cmdline = {
                            min_keyword_length = 2,
                        },
                    },
                },
                keymap = {
                    ["<C-f>"] = {}, -- Ensure that we don't clash scroll up and down with documentation scroll.
                    ["<Enter>"] = { "accept", "fallback" },
                    ["<C-y>"] = { "accept" },
                    ["<C-e>"] = { "cancel" },
                    ["<C-n>"] = { "select_next" },
                    ["<C-p>"] = { "select_prev" },
                },
                cmdline = {
                    enabled = false,
                    completion = { menu = { auto_show = true } },
                    keymap = {
                        ["<CR>"] = { "accept_and_enter", "fallback" },
                    },
                },
                completion = {
                    menu = {
                        border = nil,
                        scrolloff = 1,
                        scrollbar = false,
                        draw = {
                            columns = {
                                { "kind_icon" },
                                { "label",      "label_description", gap = 1 },
                                { "kind" },
                                { "source_name" },
                            },
                        },
                    },
                    documentation = {
                        window = {
                            border = nil,
                            scrollbar = false,
                            winhighlight = 'Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc',
                        },
                        auto_show = true,
                        auto_show_delay_ms = 500,
                    },
                },
            })

            require("luasnip.loaders.from_vscode").lazy_load()
        end,
    },
}
