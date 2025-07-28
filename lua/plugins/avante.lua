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
            behavior = {
                auto_suggestions = false, -- Experimental stage
                --auto_set_highlight_group = true,
                --auto_set_keymaps = true,
                --auto_apply_diff_after_generation = false,
                --support_paste_from_clipboard = false,
                --minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
                --enable_token_counting = true, -- Whether to enable token counting
                --auto_approve_tool_permissions = false, -- Default: show permission prompts for all tools
            },
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
            selector = {
                ---@type "fzf" | 'telescope' | "builtin" | "none"
                provider = "telescope", -- Use Telescope for selecting suggestions
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
    --{
    --    "yetone/avante.nvim",
    --    --event = "VeryLazy", -- Uncomment this only if you want to lazy load the plugin. Remove cmd and keys below if you uncommenting event
    --    cmd = { "AvanteAsk", "AvanteChat", "AvanteEdit", "AvanteRefresh", "AvanteSwitchProvider", "AvanteConflictChooseOurs", "AvanteConflictChooseTheirs", "AvanteConflictChooseBoth", "AvanteConflictChooseAllTheirs", "AvanteConflictChooseCursor", "AvanteConflictListQf", "AvanteConflictPrevConflict", "AvanteConflictNextConflict" },
    --    keys = {
    --        { "<leader>aa", "<cmd>AvanteAsk<cr>", desc = "avante: ask" },
    --        { "<leader>ar", "<cmd>AvanteRefresh<cr>", desc = "avante: refresh" },
    --        { "<leader>ae", "<cmd>AvanteEdit<cr>", desc = "avante: edit", mode = "v" },
    --    },
    --    version = false,
    --    opts = {
    --        debug = false, -- Set this to true to enable debug logging e.g. opening and closing
    --        ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
    --        ---@type Provider
    --        provider = "copilot",
    --        ---@alias Mode "agentic" | "legacy"
    --        ---@type Mode
    --        mode = "agentic", -- Chose lfacy and try auto_suggestions_provider
    --        behavior = {
    --            auto_suggestions = false, -- Experimental stage
    --            auto_set_highlight_group = true,
    --            auto_set_keymaps = true,
    --            auto_apply_diff_after_generation = false,
    --            support_paste_from_clipboard = false,
    --            minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
    --            enable_token_counting = true, -- Whether to enable token counting
    --            auto_approve_tool_permissions = false, -- Default: show permission prompts for all tools
    --        },
    --        selector = {
    --            ---@type "fzf" | 'telescope' | "builtin" | "none"
    --            provider = "telescope", -- The provider for selecting suggestions
    --        },
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
    --        mappings = {
    --            --- @class AvanteConflictMappings
    --            diff = {
    --                ours = "co",
    --                theirs = "ct",
    --                all_theirs = "ca",
    --                both = "cb",
    --                cursor = "cc",
    --                next = "]x",
    --                prev = "[x",
    --            },
    --            suggestion = {
    --                accept = "<M-l>",
    --                next = "<M-]>",
    --                prev = "<M-[>",
    --                dismiss = "<C-]>",
    --            },
    --            jump = {
    --                next = "]]",
    --                prev = "[[",
    --            },
    --            submit = {
    --                normal = "<CR>",
    --                insert = "<C-s>",
    --            },
    --            cancel = {
    --                normal = { "<C-c>", "<Esc>", "q" },
    --                insert = { "<C-c>" },
    --            },
    --            sidebar = {
    --                apply_all = "A",
    --                apply_cursor = "a",
    --                retry_user_request = "r",
    --                edit_user_request = "e",
    --                switch_windows = "<Tab>",
    --                reverse_switch_windows = "<S-Tab>",
    --                remove_file = "d",
    --                add_file = "@",
    --                close = { "<Esc>", "q" },
    --                close_from_input = { normal = {"<Esc>", "q"}, insert = "<C-c>" }
    --            },
    --        },
    --        hints = { enabled = true },
    --        windows = {
    --            ---@type "right" | "left" | "top" | "bottom"
    --            position = "right", -- the position of the sidebar
    --            wrap = true, -- similar to vim.o.wrap
    --            width = 30, -- default % based on available width
    --            sidebar_header = {
    --                enabled = true, -- true, false to enable/disable the header
    --                align = "center", -- left, center, right for title
    --                rounded = true,
    --            },
    --            spinner = {
    --                editing = { "⡀", "⠄", "⠂", "⠁", "⠈", "⠐", "⠠", "⢀", "⣀", "⢄", "⢂", "⢁", "⢈", "⢐", "⢠", "⣠", "⢤", "⢢", "⢡", "⢨", "⢰", "⣰", "⢴", "⢲", "⢱", "⢸", "⣸", "⢼", "⢺", "⢹", "⣹", "⢽", "⢻", "⣻", "⢿", "⣿" },
    --                generating = { "·", "✢", "✳", "∗", "✻", "✽" }, -- Spinner characters for the 'generating' state
    --                thinking = { "🤯", "🙄" }, -- Spinner characters for the 'thinking' state
    --            },
    --            input = {
    --                prefix = "> ",
    --                height = 8, -- Height of the input window in vertical layout
    --            },
    --            edit = {
    --                border = "rounded",
    --                start_insert = true, -- Start insert mode when opening the edit window
    --            },
    --            ask = {
    --                floating = false, -- Open the 'AvanteAsk' prompt in a floating window
    --                start_insert = true, -- Start insert mode when opening the ask window
    --                border = "rounded",
    --                ---@type "ours" | "theirs"
    --                focus_on_apply = "ours", -- which diff to focus after applying
    --            },
    --        },
    --        highlights = {
    --            ---@type AvanteConflictHighlights
    --            diff = {
    --                current = "DiffText",
    --                incoming = "DiffAdd",
    --            },
    --        },
    --        --- @class AvanteConflictUserConfig
    --        diff = {
    --            autojump = true,
    --            ---@type string | fun(): any
    --            list_opener = "copen",
    --            --- Override the 'timeoutlen' setting while hovering over a diff
    --            override_timeoutlen = 500,
    --        },
    --    },
    --    build = "make",
    --    dependencies = {
    --        "zbirenbaum/copilot.lua", -- Required for copilot provider
    --        "MunifTanjim/nui.nvim",
    --        "MeanderingProgrammer/render-markdown.nvim", -- Required for rendering markdown
    --        "nvim-treesitter/nvim-treesitter",   -- Already installed 
    --        "stevearc/dressing.nvim", -- Input prompt  and selection menu
    --        "nvim-lua/plenary.nvim", -- utility functions
    --        "nvim-tree/nvim-web-devicons",
    --        "Kaiser-Yang/blink-cmp-avante", -- Autocompletion for Avante configured already in blink-cmp.lua
    --        --"hrsh7th/nvim-cmp",
    --        -- Optional:
    --        --"echasnovski/mini.pick",
    --        --"nvim-telescope/telescope.nvim",
    --        --"ibhagwan/fzf-lua",
    --    },
    --},
    --{
    --    -- Make sure to set this up properly if you have lazy=true
    --    'MeanderingProgrammer/render-markdown.nvim',  -- Required for rendering markdown
    --    opts = {
    --        file_types = { "markdown", "Avante" }, -- Decides to render markdown files first and then Avante files
    --    },
    --    ft = { "markdown", "Avante" },
    --},
}
