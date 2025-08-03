return {
    {
        "yetone/avante.nvim",
        --event = "VeryLazy",
        version = false,
        cmd = { "AvanteAsk", "AvanteChat", "AvanteEdit", "AvanteRefresh", "AvanteSwitchProvider", "AvanteConflictChooseOurs", "AvanteConflictChooseTheirs", "AvanteConflictChooseBoth", "AvanteConflictChooseAllTheirs", "AvanteConflictChooseCursor", "AvanteConflictListQf", "AvanteConflictPrevConflict", "AvanteConflictNextConflict" },
        keys = {
            { "<leader>aa", "<cmd>AvanteAsk<cr>", desc = "avante: ask" },
            { "<leader>ar", "<cmd>AvanteRefresh<cr>", desc = "avante: refresh" },
            { "<leader>ae", "<cmd>AvanteEdit<cr>", desc = "avante: edit", mode = "v" },
        },
        opts = {
            --debug = true, -- Debug mode for troubleshooting plugin issues
            provider = "copilot", -- AI provider for suggestions
            --auto_suggestions_provider = nil, -- Enable Copilot for auto suggestions
            --auto_suggestions_provider = "copilot", -- Enable Copilot for auto suggestions
            ---@alias Mode "agentic" | "legacy"
            ---@type Mode
            --mode = "agentic", -- Chose legacy and try auto_suggestions_provider

            -- Permanently set Copilot model version
            providers = {
                ---@type AvanteProviderConfig
                copilot = {
                    model = "claude-3.7-sonnet", -- Set the specific model version permanently
                    extra_request_body = {
                        --temperature = 1, -- Set the temperature for Copilot suggestions
                    },
                    auto_select_model = false, -- Prevent Avante from selecting a different model
                },
            },
            hints = { enabled = true },
            selector = {
                ---@type "fzf" | 'telescope' | "builtin" | "none"
                provider = "telescope", -- Use Telescope for selecting suggestions
            },
            behavior = {
                auto_suggestions = false, -- Experimental stage
                --auto_set_highlight_group = true,
                --auto_set_keymaps = true,
                --auto_apply_diff_after_generation = false,
                support_paste_from_clipboard = false,
                --minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
                enable_token_counting = true, -- Whether to enable token counting
                --auto_approve_tool_permissions = false, -- Default: show permission prompts for all tools
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
                    start_insert = true, -- Start in insert mode when opening the edit window
                },
                ask = {
                    floating = false,
                    start_insert = true,
                    border = "rounded",
                    focus_on_apply = "ours",
                },
            },
            highlights = {
                ---@type AvanteConflictHighlights
                diff = {
                    current = "DiffText", -- Highlight for our changes
                    incoming = "DiffAdd", -- Highlight for Avante's suggestions
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
                    details = "Automatically refactor code to improve readability, maintainability, and follow best practices while preserving functionality",
                    prompt = "Please check pylint issues and autopep8 issues and refactor this code following best practices, improving readability and maintainability while preserving functionality. Ensure to add the right comments in the docstrings"
                },
            },
        },
        input = {
            provider = "dressing",  -- Without this section, you won't be able to focus on the confirmation page and come out of it
            provider_opts = {},
        },
        build = "make",
        dependencies = {
            "zbirenbaum/copilot.lua", -- Required for copilot provider
            "nvim-tree/nvim-web-devicons", -- File type icons
            "nvim-lua/plenary.nvim", -- Utility functions
            "stevearc/dressing.nvim", -- Input prompts and selection menus
            "MunifTanjim/nui.nvim", -- UI components
            "nvim-treesitter/nvim-treesitter", -- Syntax highlighting and parsing
        },
    },
    {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',  -- Required for rendering markdown
        opts = {
            file_types = { "markdown", "Avante" }, -- Decides to render markdown files first and then Avante files
        },
        ft = { "markdown", "Avante" },
    },
}
