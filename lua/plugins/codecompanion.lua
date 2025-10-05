return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        { "nvim-lua/plenary.nvim", branch = "master" },
        {
            "MeanderingProgrammer/render-markdown.nvim",
            ft = { "markdown", "codecompanion" },
            --lazy = false,
        },
        {
            "OXY2DEV/markview.nvim",
            lazy = false,
            opts = {
                preview = {
                    filetypes = { "markdown", "codecompanion" },
                    ignore_buftypes = {},
                },
            },
        },
        {
            "echasnovski/mini.diff",
            config = function()
                local diff = require("mini.diff")
                diff.setup({
                    source = diff.gen_source.none(),
                })
            end,
        },
    },
    opts = {
        adapter = {
            opts = {
                show_model_choices = true,
            },
        },
        strategies = {
            chat = {
                roles = { user = "Bidhov" },
                adapter = {
                    name = "copilot",
                    model = "claude-sonnet-4",
                },
                opts = {
                    completion_provider = "blink", -- blink|cmp|coc|default
                },
                slash_commands = {
                    ["file"] = {
                        -- Location to the slash command in CodeCompanion
                        callback = "strategies.chat.slash_commands.file",
                        description = "Select a file using Telescope",
                        opts = {
                            provider = "telescope", -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks"
                            contains_code = true,
                        },
                    },
                },
                variables = {
                    ["buffer"] = {
                        opts = {
                            -- While using #buffer in CodeCompanion chat the context can be controlled with:
                            -- pin: Is used to pins the entire buffer (sends entire buffer on changes)
                            -- watch: Is used to watches the change in the buffer (sends only diffs on changes)
                            default_params = 'pin', -- or 'watch'

                            -- Another way to use the
                            --     #{buffer}{pin} - Pins the buffer (sends entire buffer on changes)
                            --     #{buffer}{watch} - Watches for changes (sends only changes)
                            --     #{buffer:config.lua}{pin} - Combines targeting with parameters
                        },
                    },
                },
            },
            inline = {
                adapter = {
                    name = "copilot",
                    model = "claude-sonnet-4",
                },
                keymaps = {
                    accept_change = {
                        modes = { n = "ct" }, -- Remember this as DiffAccept
                    },
                    reject_change = {
                        modes = { n = "co" }, -- Remember this as DiffReject
                    },
                    always_accept = {
                        modes = { n = "cT" }, -- Remember this as DiffYolo
                    },
                },
            },
            agent = {
                adapter = {
                    name = "copilot",
                    model = "claude-sonnet-4",
                },
            },
        },
        memory = {
            opts = {
                chat = {
                    enabled = true,
                },
            },
        },
        display = {
            chat = {
                intro_message = "Welcome to CodeCompanion ✨! Press ? for help",
                separator = "-", -- The separator between the different messages in the chat buffer
                show_context = true, -- Show context (from slash commands and variables) in the chat buffer?
                show_header_separator = true, -- Show header separators in the chat buffer? Set this to false if you're using an external markdown formatting plugin
                show_settings = true, -- Show LLM settings at the top of the chat buffer?
                show_token_count = false, -- Show the token count for each response?
                show_tools_processing = true, -- Show the loading message when tools are being executed?
                start_in_insert_mode = false, -- Open the chat buffer in insert mode?
            },
            action_palette = {
                width = 95,
                height = 10,
                prompt = "Prompt ", -- Prompt used for interactive LLM calls
                provider = "telescope", -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks".
                opts = {
                    show_default_actions = true, -- Show the default actions in the action palette?
                    show_default_prompt_library = true, -- Show the default prompt library in the action palette?
                    title = "CodeCompanion actions", -- The title of the action palette
                },
            },
            diff = {
                enabled = true,
                provider = 'mini_diff', -- mini_diff|split|inline

                provider_opts = {
                    -- Options for inline diff provider
                    inline = {
                        layout = "float", -- float|buffer - Where to display the diff

                        diff_signs = {
                            signs = {
                                text = "▌", -- Sign text for normal changes
                                reject = "✗", -- Sign text for rejected changes in super_diff
                                highlight_groups = {
                                    addition = "Question",
                                    deletion = "Visual",
                                    modification = "DiagnosticWarn",
                                },
                            },
                            -- Super Diff options
                            icons = {
                                accepted = " ",
                                rejected = " ",
                            },
                            colors = {
                                accepted = "WildMenu",
                                rejected = "DiagnosticError",
                            },
                        },

                        opts = {
                            context_lines = 3, -- Number of context lines in hunks
                            dim = 25, -- Background dim level for floating diff (0-100, [100 full transparent], only applies when layout = "float")
                            full_width_removed = true, -- Make removed lines span full width
                            show_keymap_hints = true, -- Show "gda: accept | gdr: reject" hints above diff
                            show_removed = true, -- Show removed lines as virtual text
                        },
                    },

                    -- Options for the split provider
                    split = {
                        close_chat_at = 240, -- Close an open chat buffer if the total columns of your display are less than...
                        layout = "vertical", -- vertical|horizontal split
                        opts = {
                            "internal",
                            "filler",
                            "closeoff",
                            "algorithm:histogram", -- https://adamj.eu/tech/2024/01/18/git-improve-diff-histogram/
                            "indent-heuristic", -- https://blog.k-nut.eu/better-git-diffs
                            "followwrap",
                            "linematch:120",
                        },
                    },
                },
            },
            -- window = {
            --     layout = "buffer", -- float|vertical|horizontal|buffer
            --     position = nil, -- left|right|top|bottom (nil will default depending on vim.opt.splitright|vim.opt.splitbelow)
            --     border = "rounded",
            --     height = 0.8,
            --     width = 0.45,
            --     relative = "editor",
            --     full_height = false, -- when set to false, vsplit will be used to open the chat buffer vs. botright/topleft vsplit
            --     sticky = true, -- when set to true and `layout` is not `"buffer"`, the chat buffer will remain opened when switching tabs
            --     opts = {
            --         breakindent = true,
            --         cursorcolumn = true,
            --         cursorline = true,
            --         foldcolumn = "0",
            --         linebreak = true,
            --         list = true,
            --         numberwidth = 1,
            --         signcolumn = "yes",
            --         spell = true,
            --         wrap = true,
            --     },
            -- },
        },
    },
    keys = {
        -- Open action palette (works in normal and visual mode)
        { "<leader>cp", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "CodeCompanion Actions" },

        -- Toggle chat buffer
        { "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "Toggle Chat" },

        -- Add visual selection to chat
        { "<leader>ca", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "Add to Chat" },

        -- Quick prompts from prompt library
        { "<leader>ce", "<cmd>CodeCompanion /explain<cr>", mode = "v", desc = "Explain Code" },
        { "<leader>cf", "<cmd>CodeCompanion /fix<cr>", mode = "v", desc = "Fix Code" },
        { "<leader>ct", "<cmd>CodeCompanion /tests<cr>", mode = "v", desc = "Generate Tests" },
        { "<leader>cl", "<cmd>CodeCompanion /lsp<cr>", mode = "v", desc = "Explain LSP Diagnostics" },
        { "<leader>cm", "<cmd>CodeCompanion /commit<cr>", mode = "n", desc = "Generate Commit Message" },
        { "<leader>cg", "<cmd>CodeCompanionAgent<cr>", mode = { "n", "v" }, desc = "CodeCompanion Agent" },

        -- Inline assistant
        { "<leader>ci", "<cmd>CodeCompanion<cr>", mode = { "n", "v" }, desc = "Inline Assistant" },

        -- CodeCompanion Help
        { "<leader>ch", "<cmd>help CodeCompanion<cr>", mode = "n", desc = "Open CodeCompanion Documentation" },

    },
    config = function(_, opts)
        require("codecompanion").setup(opts)

        -- Expand 'cc' into 'CodeCompanion' in command line
        vim.cmd([[cab cc CodeCompanion]])
    end,
}
