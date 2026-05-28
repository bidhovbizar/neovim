return {
    "folke/zen-mode.nvim",
    -- Other options: "BufReadPost", "InsertEnter", or specific filetypes
    event = "VeryLazy", -- loads after startup

    opts = {
        window = {
            -- backdrop: Shade level for the area outside the Zen window.
            -- Range: 0 (fully transparent) to 1 (fully opaque/black)
            -- 0.95 = strong dimming, 0.5 = moderate, 0 = no dimming
            backdrop = 0.95,

            -- width: Width of the Zen window.
            -- Float (0-1): Percentage of editor width (0.95 = 95%)
            -- Integer: Fixed column count (e.g., 120 = 120 columns)
            width = 0.95,

            -- height: Height of the Zen window.
            -- Float (0-1): Percentage of editor height (0.95 = 95%)
            -- Integer: Fixed line count (e.g., 40 = 40 lines)
            height = 0.95,

            -- options: Vim window-local options applied inside the Zen window.
            -- These override your global settings only while Zen Mode is active.
            options = {
                number = true, -- show line number
                relativenumber = false, -- show relative line numbers

                -- signcolumn: Column for signs (diagnostics, git, breakpoints).
                -- "yes" = always show (prevents text shifting), "no" = never show
                -- "auto" = show only when signs exist, "number" = display signs in the number column
                signcolumn = "yes",

                cursorline = false, -- highlight which line cursor

                -- foldcolumn: Width of the fold indicator column.
                -- "0" = hidden (cleaner look), "1"-"9" = fixed width, "auto" = auto-size based on fold depth
                foldcolumn = "auto",
            },
        },

        plugins = {
            -- options: Controls global Vim options while Zen Mode is active.
            options = {
                -- enabled: Whether to apply the option overrides below.
                -- true = apply these settings, false = keep normal settings
                enabled = true,

                -- ruler: Show cursor position (line,col) in the command line.
                ruler = true,

                -- showcmd: Show partial commands in the last line of the screen.
                -- true = show commands as you type, false = hide them
                showcmd = true,

                -- laststatus: When to show the statusline.
                -- 0 = never show statusline
                -- 1 = show only if there are multiple windows
                -- 2 = always show statusline
                -- 3 = global statusline (one statusline for all windows)
                laststatus = 3,
            },

            -- Plugin integrations: Control how other plugins behave during Zen Mode.

            -- twilight: Dims inactive portions of code (requires folke/twilight.nvim).
            -- enabled = true: Activate Twilight when entering Zen Mode
            -- enabled = false: Keep Twilight inactive
            twilight = { enabled = false },

            -- gitsigns: Git diff signs in the gutter (requires lewis6991/gitsigns.nvim).
            -- true: Keep gitsigns visible in Zen Mode, false: Hide gitsigns during Zen Mode
            gitsigns = { enabled = true },

            -- tmux: Automatically maximize tmux pane when entering Zen Mode.
            -- enabled = true: Maximize tmux pane (if running in tmux)
            -- enabled = false: Leave tmux pane unchanged
            tmux = { enabled = false },
        },
    },

    -- Keymaps: Registered when the plugin loads.
    keys = {
        -- Primary toggle: Enter/exit Zen Mode for distraction-free editing.
        { "<leader>z", "<cmd>ZenMode<cr>", desc = "Toggle Zen Mode for current buffer" },

        -- Quick window helpers: Zen-like behavior without the plugin.
        -- <C-w>| = maximize width, <C-w>_ = maximize height
        vim.keymap.set("n", "<leader>wz", "<C-w>|<C-w>_", { desc = "Maximize current window" }),

        -- Reset all windows to equal sizes.
        vim.keymap.set("n", "<leader>w=", "<C-w>=", { desc = "Equalize windows" }),
    },
}
