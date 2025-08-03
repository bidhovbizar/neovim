return {
    { 
        "L3MON4D3/LuaSnip",
        event = "InsertEnter",
    },
    {
        -- Add blink-cmp-avante as a separate plugin that loads first
        "Kaiser-Yang/blink-cmp-avante",
        lazy = true, -- Changed: Let it load when needed by blink.cmp
    },
    {
        "saghen/blink.cmp",
        event = "InsertEnter",
        dependencies = {
            "rafamadriz/friendly-snippets",
            "Kaiser-Yang/blink-cmp-avante", -- Dependency ensures proper load order
        },
        version = "*",
        config = function()
            require("blink.cmp").setup({
                snippets = { preset = "luasnip" },
                signature = { enabled = true },

                keymap = { preset = "default" },

                sources = {
                    default = { "lazydev", "avante", "lsp", "path", "snippets", "buffer" },

                    per_filetype = {
                        -- Fixed: Correct filetype name (capital A)
                        Avante = { "avante", "path", "buffer" },
                        -- Also add lowercase variant just in case
                        avante = { "avante", "path", "buffer" },
                        -- Lazydev works correctly with lua
                        lua = { "lazydev", "lsp", "path", "snippets", "buffer" },
                    },

                    providers = {
                        path = {
                            name = 'Path',
                            module = 'blink.cmp.sources.path',
                            score_offset = 3,
                            opts = {
                                trailing_slash = false,
                                label_trailing_slash = true,
                                get_cwd = function(context)
                                    return vim.fn.expand(('#%d:p:h'):format(context.bufnr))
                                end,
                                show_hidden_files_by_default = false,
                            }
                        },

                        avante = {
                            module = 'blink-cmp-avante',
                            name = 'Avante',
                            score_offset = 500, -- Added: High priority for @ and / triggers
                            opts = {
                                -- Options for blink-cmp-avante
                            }
                        },
                        lazydev = {
                            name = "LazyDev",
                            module = "lazydev.integrations.blink",
                            score_offset = 300, -- High priority for Lua development
                        },

                        cmdline = {
                            min_keyword_length = 2,
                        },
                    },
                },

                -- Fixed: Removed duplicate keymap section and consolidated
                keymap = {
                    ["<C-f>"] = {}, -- Don't clash with documentation scroll
                    ["<Enter>"] = { "accept", "fallback" },
                    ["<C-y>"] = { "accept" },
                    ["<C-e>"] = { "cancel" },
                    ["<C-n>"] = { "select_next" },
                    ["<C-p>"] = { "select_prev" },
                    -- Added: More navigation options
                    ["<Tab>"] = { "select_next", "fallback" },
                    ["<S-Tab>"] = { "select_prev", "fallback" },
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
                                { "label", "label_description", gap = 1 },
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

                -- Added: Enable completion in special buffer types (important for Avante)
                enabled = function()
                    local buftype = vim.api.nvim_get_option_value("buftype", { buf = 0 })
                    local filetype = vim.api.nvim_get_option_value("filetype", { buf = 0 })

                    -- Enable in Avante buffers specifically
                    if filetype == "Avante" or filetype == "avante" then
                        return true
                    end

                    -- Enable in normal files, disable in prompt/nofile buffers
                    return not vim.tbl_contains({ "prompt" }, buftype) or buftype == ""
                end,
            })

            require("luasnip.loaders.from_vscode").lazy_load()
        end,
    },
}
