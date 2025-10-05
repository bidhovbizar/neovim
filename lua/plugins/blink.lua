return {
    --{
    --    "L3MON4D3/LuaSnip",
    --    lazy = true, -- Make LuaSnip lazy
    --    event = "InsertEnter",
    --},
    {
        -- Add blink-cmp-avante as a separate plugin that loads first
        "Kaiser-Yang/blink-cmp-avante",
        lazy = true, -- Changed: Let it load when needed by blink.cmp
    },
    {
        "saghen/blink.cmp",
        --priority = 600, -- Ensure it loads after blink-cmp-avante
        event = { "InsertEnter" }, -- Load on insert or command mode
        --event = { "InsertEnter", "CmdlineEnter" }, -- Load on insert or command mode
        lazy = true, -- Make blink.cmp lazy too
        dependencies = {
            {
                "rafamadriz/friendly-snippets",
                lazy = true,
            },
            "Kaiser-Yang/blink-cmp-avante", -- Dependency ensures proper load order
            {
                "L3MON4D3/LuaSnip",
                lazy = true,
                event = "InsertEnter", -- Only load when entering insert mode
                config = function()
                    -- Move LuaSnip loading here to avoid loading on startup
                    --require("luasnip.loaders.from_vscode").lazy_load()
                    -- Only load VSCode snippets once, and do it lazily
                    -- Defer snippet loading until actually needed
                    local function load_snippets()
                        if not vim.g.luasnip_snippets_loaded then
                            vim.g.luasnip_snippets_loaded = true
                            require("luasnip.loaders.from_vscode").lazy_load()
                        end
                    end

                    -- Load snippets only when first snippet is requested
                    local orig_get_snippets = require("luasnip").get_snippets
                    require("luasnip").get_snippets = function(...)
                        load_snippets()
                        require("luasnip").get_snippets = orig_get_snippets
                        return orig_get_snippets(...)
                    end
                end,
            },
        },
        version = "1.*",
        opts_extend = { "sources.default" }, -- Add this line
        config = function()
            require("blink.cmp").setup({
                snippets = {
                    preset = "luasnip"
                    -- Disable snippet expansion on startup
                    --expand = function(snippet)
                    --    -- Ensure LuaSnip is loaded before expanding
                    --    if not vim.g.luasnip_snippets_loaded then
                    --        require("luasnip.loaders.from_vscode").lazy_load()
                    --        vim.g.luasnip_snippets_loaded = true
                    --    end
                    --    require("luasnip").lsp_expand(snippet)
                    --end,
                },
                signature = { enabled = true },

                sources = {
                    default = { "lsp", "lazydev", "path", "snippets", "buffer", "avante" },

                    per_filetype = {
                        -- Fixed: Correct filetype name (capital A)
                        Avante = { "avante", "path", "buffer", "lsp" },
                        -- Also add lowercase variant just in case
                        avante = { "avante", "path", "buffer", "lsp" },
                        -- Lazydev works correctly with lua
                        lua = { "lazydev", "lsp", "path", "snippets", "buffer" },
                        -- Add Python-specific optimization
                        python = { "lsp", "path", "snippets", "buffer" },
                        -- CodeCompanion specific settings
                        codecompanion = { "codecompanion", "lsp", "path", "buffer" },
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
                            opts = {
                                trigger_characters = { "@", "/" },
                                score_offset = 500, -- Added: High priority for @ and / triggers
                            }
                        },
                        lazydev = {
                            name = "LazyDev",
                            module = "lazydev.integrations.blink",
                            score_offset = 300, -- High priority for Lua development
                        },

                        -- Optimize buffer source
                        buffer = {
                            max_items = 20, -- Limit buffer completions
                            min_keyword_length = 2,
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
                    list = {
                        max_items = 20, -- Limit items for performance
                    },

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

                --trigger = {
                --    completion = {
                --        keyword_length = 1, -- Allow single character triggers like @
                --        --keyword_regex = "[%w@/]", -- Include @ and / in keyword matching
                --    },
                --},

                -- Added: Enable completion in special buffer types (important for Avante)
                enabled = function()
                    local buftype = vim.api.nvim_get_option_value("buftype", { buf = 0 })
                    local filetype = vim.api.nvim_get_option_value("filetype", { buf = 0 })

                    -- Enable in Avante and CodeCompanion buffers specifically
                    if filetype == "Avante" or filetype == "avante" or filetype == "codecompanion" then
                        return true
                    end

                    -- Enable in normal files, disable in prompt/nofile buffers
                    return not vim.tbl_contains({ "prompt" }, buftype) or buftype == ""
                end,

                -- Add fuzzy matcher configuration
                fuzzy = {
                    implementation = "prefer_rust_with_warning",
                },
            })

            -- Defer LuaSnip keymap setup
            vim.schedule(function()
                local ls = require("luasnip")

                -- Map functionality to <M-k> combination
                vim.keymap.set({ "i", "s" }, "<M-k>", function()
                    local blink = require("blink.cmp")
                    if blink.is_visible() then
                        blink.select_next()
                    elseif ls.jumpable(1) then
                        ls.jump(1)
                    else
                        return "<M-k>"
                    end
                end, { expr = true, silent = true })

                -- Map functionality to <M-j> combination
                vim.keymap.set({ "i", "s" }, "<M-j>", function()
                    local blink = require("blink.cmp")
                    if blink.is_visible() then
                        blink.select_prev()
                    elseif ls.jumpable(-1) then
                        ls.jump(-1)
                    else
                        return "<M-j>"
                    end
                end, { expr = true, silent = true })
            end)

            --require("luasnip.loaders.from_vscode").lazy_load()
        end,
    },
}
