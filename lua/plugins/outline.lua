return {
    "hedyhli/outline.nvim",
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    keys = {
        { "<leader>o", "<cmd>Outline<CR>", desc = "Toggle outline" },
    },
    opts = {
        -- Outline window configuration
        outline_window = {
            position = "right", -- 'left' or 'right'
            width = 25, -- Slightly smaller for better screen usage
            relative_width = true, -- Use percentage of screen width
            auto_close = true, -- Auto close the outline window if goto_location is triggered and not for
            auto_jump = false, -- Don't auto-jump to outline when opened
            jump_highlight_duration = 300, -- Duration of highlight when jumping
            center_on_jump = true, -- Center the cursor when jumping to symbol
            show_numbers = false, -- Don't show line numbers (cleaner look)
            show_relative_numbers = false,
            wrap = false,
            focus_on_open = false, -- Don't focus outline window on open
            winhl = "", -- Custom window highlighting
        },

        -- Outline tree configuration
        outline_items = {
            show_symbol_details = true, -- Show extra symbol details
            show_symbol_lineno = true, -- Don't show line numbers next to symbols
            highlight_hovered_item = false, --DOn't highlight item under cursor
            -- auto_set_cursor and auto_update_events go hand in hand
            auto_set_cursor = true, -- Auto set cursor to nearest symbol when moving in the code
            auto_update_events = {
                follow = { "CursorMoved" }, -- Update outline when cursor moves
                items = { "InsertLeave", "WinEnter", "BufEnter", "BufWinEnter", "TabEnter", "BufWritePost" },
            },
        },

        -- Guide configuration (connecting lines)
        guides = {
            enabled = true,
            markers = {
                bottom = "└",
                middle = "├",
                vertical = "│",
                horizontal = "─",
            },
        },

        -- Symbol configuration
        symbol_folding = {
            autofold_depth = 1, -- Auto-fold symbols deeper than this level
            auto_unfold = {
                hovered = true, -- Unfold when hovering
                only = true, -- Only unfold the hovered item
            },
            markers = { "", "" }, -- Folding markers (using simple chars for compatibility)
        },

        -- Preview window configuration
        preview_window = {
            auto_preview = false, -- Don't auto-preview on hover
            open_hover_on_preview = false,
            width = 50, -- Preview window width
            min_width = 50,
            relative_width = true,
            border = "rounded", -- Border style: 'single', 'double', 'rounded', 'solid', 'shadow'
            winhl = "NormalFloat:",
        },

        -- Keymaps for the outline window
        keymaps = {
            show_help = "?",
            close = { "q", "<Esc>" },
            goto_location = "<CR>",
            peek_location = "o",
            goto_and_close = "<S-CR>",
            restore_location = "<C-g>",
            hover_symbol = "<C-space>",
            toggle_preview = "K",
            rename_symbol = "r",
            code_actions = "a",
            fold = "h",
            unfold = "l",
            fold_toggle = "<Tab>",
            fold_toggle_all = "<S-Tab>",
            fold_all = "W",
            unfold_all = "E",
            fold_reset = "R",
            down_and_jump = "<C-j>",
            up_and_jump = "<C-k>",
        },

        -- Provider configuration (LSP symbols)
        providers = {
            priority = { "lsp", "coc", "markdown", "norg" },
            lsp = {
                blacklist_clients = {}, -- LSP clients to ignore
            },
        },

        -- Symbol icons (using simple characters for non-nerd font compatibility)
        symbols = {
            icons = {
                File = { icon = "F", hl = "Identifier" },
                Module = { icon = "M", hl = "Include" },
                Namespace = { icon = '󰅪', hl = 'Include' },
                Package = { icon = '󰏗', hl = 'Include' },
                Class = { icon = "C", hl = "Type" },
                Method = { icon = "m", hl = "Function" },
                Property = { icon = "p", hl = "Identifier" },
                Field = { icon = "f", hl = "Identifier" },
                Constructor = { icon = '', hl = 'Special' },
                Enum = { icon = "E", hl = "Type" },
                Interface = { icon = "I", hl = "Type" },
                Function = { icon = "f", hl = "Function" },
                Variable = { icon = "v", hl = "Constant" },
                Constant = { icon = "c", hl = "Constant" },
                String = { icon = "s", hl = "String" },
                Number = { icon = "n", hl = "Number" },
                Boolean = { icon = "b", hl = "Boolean" },
                Array = { icon = "a", hl = "Constant" },
                Object = { icon = "o", hl = "Type" },
                Key = { icon = "k", hl = "Type" },
                Null = { icon = 'NULL', hl = 'Type' },
                EnumMember = { icon = "e", hl = "Identifier" },
                Struct = { icon = "S", hl = "Structure" },
                Event = { icon = "E", hl = "Type" },
                Operator = { icon = "+", hl = "Identifier" },
                TypeParameter = { icon = "T", hl = "Identifier" },
                Component = { icon = "C", hl = "Function" },
                Fragment = { icon = "F", hl = "Constant" },
                TypeAlias = { icon = "T", hl = "Type" },
                Parameter = { icon = "p", hl = "Identifier" },
                StaticMethod = { icon = "s", hl = "Function" },
                Macro = { icon = "M", hl = "Function" },
            },
        },
    },
}
