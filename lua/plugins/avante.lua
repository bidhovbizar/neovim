return {
    {
        "yetone/avante.nvim",
        --tag = "v0.0.25",
        --event = "VeryLazy", -- Don't uncomment, as it will load the plugin even if not needed
        lazy = true,
        version = false,
        keys = {
            { "<leader>aa", "<cmd>AvanteAsk<cr>",     desc = "avante: ask" },
            { "<leader>ar", "<cmd>AvanteRefresh<cr>", desc = "avante: refresh" },
            { "<leader>ae", "<cmd>AvanteEdit<cr>",    desc = "avante: edit",   mode = "v" },
        },
        opts = {
            --debug = true, -- Debug mode for troubleshooting plugin issues
            --instructions_file = "avante.md", -- File containing default instructions for Avante
            provider = "copilot", -- AI provider for suggestions
            --auto_suggestions_provider = nil, -- Enable Copilot for auto suggestions
            --auto_suggestions_provider = "copilot", -- Enable Copilot for auto suggestions
            ---@alias Mode "agentic" | "legacy"
            ---@type Mode
            --Legacy mode: AI provides suggestions and plans but requires manual approval for all actions
            --Agentic mode: AI can automatically execute tools like file operations, bash commands, web searches, etc. to complete complex tasks
            mode = "agentic", -- Use agentic mode for better permission handling

            -- Permanently set Copilot model version
            providers = {
                copilot = {
                    -- Use <leader>a? to find the list of all the models available. Set the specific model version permanently
                    --model = "claude-sonnet-4", -- Best allrounder model but slower
                    model = "claude-sonnet-4.5", -- Used for thinking response faster
                    --model = "gpt-4o-2024-11-20",  -- Used for super faster response but it may get stuck in loop
                    extra_request_body = {
                        --temperature = 1, -- Set the temperature for Copilot suggestions
                    },
                    auto_select_model = false, -- Prevent Avante from selecting a different model
                },
            },
            hints = { enabled = true },
            selector = {
                --- @alias avante.SelectorProvider "native" | "fzf_lua" | "mini_pick" | "snacks" | "telescope" | fun(selector: avante.ui.Selector): nil
                --- @type "fzf" | 'telescope' | "builtin" | "none"
                provider = "telescope", -- Use Telescope for selecting suggestions
            },
            behaviour = {
                auto_suggestions = false,        -- Experimental stage
                auto_set_highlight_group = true, -- Assists in better colour scheme for avante
                auto_set_keymaps = true,         -- Automatically set keymaps for avante
                auto_apply_diff_after_generation = false,
                support_paste_from_clipboard = false,
                --minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
                enable_token_counting = false,         -- Whether to enable token counting
                auto_approve_tool_permissions = false, -- Default: show permission prompts for all tools
                -- auto_approve_tool_permissions = {"bash", "replace_in_file"},
                enable_fastapply = false,              -- Enable Fast Apply feature
            },
            --        prompt_logger = { -- logs prompts to disk (timestamped, for replay/debugging)
            --            enabled = true, -- toggle logging entirely
            --            log_dir = vim.fn.stdpath("cache") .. "/avante_prompts", -- directory where logs are saved
            --            fortune_cookie_on_success = false, -- shows a random fortune after each logged prompt
            --            next_prompt = {
            --                normal = "<C-n>", -- load the next (newer) prompt log in normal mode
            --                insert = "<C-n>",
            --            },
            --            prev_prompt = {
            --                normal = "<C-p>", -- load the previous (older) prompt log in normal mode
            --                insert = "<C-p>",
            --            },
            --        },
            windows = {
                position = "right",
                wrap = true,
                width = 30, -- Increase overall width if needed
                sidebar_header = {
                    enabled = true,
                    align = "center",
                    rounded = true,
                },
                input = {
                    prefix = "> ",
                    height = 8, -- Increase input area height
                },
                edit = {
                    border = "rounded",
                    start_insert = false, -- Start in insert mode when opening the edit window
                },
                ask = {
                    floating = false,
                    start_insert = false,
                    border = "rounded",
                    focus_on_apply = "ours",
                },
            },
            highlights = {
                diff = {
                    current = "Visual",    -- Highlight for our changes
                    incoming = "Question", -- Highlight for Avante's suggestions
                    --current = "DiffText", -- Default: Highlight for our changes, seen on top
                    --incoming = "DiffAdd", -- Default: Highlight for Avante's suggestions, seen on bottom
                },
            },
            --- @class AvanteConflictUserConfig
            diff = {
                autojump = true,
                ---@type string | fun(): any
                list_opener = "copen",
                --- Override the 'timeoutlen' setting while hovering over a diff (see :help timeoutlen).
                --- Helps to avoid entering operator-pending mode with diff mappings starting with `c`.
                --- Disable by setting to -1.
                override_timeoutlen = 500,
            },
            shortcuts = {
                {
                    name = "CiscoCodeReview",
                    description = "Reviews the code as per cisco policy",
                    details =
                    "Automatically refactor code to improve readability, maintainability, and follow best practices while preserving functionality",
                    prompt =
                    "Please check pylint issues and autopep8 issues and refactor this code following best practices, improving readability and maintainability while preserving functionality. Ensure to add the right comments in the docstrings"
                },
            },
            input = {
                provider = "dressing", -- Without this section, you won't be able to focus on the confirmation page and come out of it
                provider_opts = {},    -- For dressing this field should be empty
            },
        },
        build = "make",
        dependencies = {
            "nvim-lua/plenary.nvim",           -- Utility functions
            "MunifTanjim/nui.nvim",            -- UI components
            "nvim-telescope/telescope.nvim",   -- for file_selector provider telescope
            "stevearc/dressing.nvim",          -- Input prompts and selection menus
            "folke/snacks.nvim",               -- for input provider snacks
            "nvim-tree/nvim-web-devicons",     -- File type icons
            "nvim-treesitter/nvim-treesitter", -- Syntax highlighting and parsing
            "zbirenbaum/copilot.lua",          -- Required for copilot provider
            -- Remember avante and codecompanion both use markdown config changes should be made in both
            {
                'MeanderingProgrammer/render-markdown.nvim',
                ft = { "markdown", "Avante", "AvanteSelectedFiles", "AvanteInput",
                    "AvanteConfirm", "AvantePromptInput", "AvanteTodos", "codecompanion" },
                opts = {
                    file_types = { "markdown", "Avante", "AvanteSelectedFiles", "AvanteInput",
                        "AvanteConfirm", "AvantePromptInput", "AvanteTodos", "codecompanion" },
                    render_modes = true,
                },
                config = function(_, opts)
                    require("render-markdown").setup(opts)
                end,
            },
        },
    },
}
