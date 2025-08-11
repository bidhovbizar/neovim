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
        --priority = 600, -- Ensure it loads after blink-cmp-avante
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
                                trigger_characters = { "@", "/" },
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
                    preset = "default", -- Keep the default preset
                    ["<C-f>"] = {}, -- Don't clash with documentation scroll
                    ["<Enter>"] = { "accept", "fallback" },
                    --['<Esc>'] = { 'hide', 'fallback' },  -- Uncommenting this will make 1st Esc quit autocompletion then 2nd Esc will quit to n mode
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

                    trigger = {
                        completion = {
                            keyword_length = 1, -- Allow single character triggers like @
                            keyword_regex = "[%w@/]", -- Include @ and / in keyword matching
                        },
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
            local ls = require("luasnip")

            -- Map functionality to <M-j> combination
            vim.keymap.set({ "i", "s" }, "<M-j>", function()
                local blink = require("blink.cmp")
                if blink.is_visible() then
                    blink.select_next()
                elseif ls.jumpable(1) then
                    ls.jump(1)
                else
                    return "<M-j>"
                end
            end, { expr = true, silent = true })

            -- Map functionality to <M-k> combination
            vim.keymap.set({ "i", "s" }, "<M-k>", function()
                local blink = require("blink.cmp")
                if blink.is_visible() then
                    blink.select_prev()
                elseif ls.jumpable(-1) then
                    ls.jump(-1)
                else
                    return "<M-k>"
                end
            end, { expr = true, silent = true })

            require("luasnip.loaders.from_vscode").lazy_load()
        end,
    },
}
