return {
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        build = ":Copilot auth",
        opts = {
            debug = true,
            suggestion = {
                enabled = true,
                auto_trigger = true,
                debounce = 75,
                keymap = {
                    --accept = "<Tab>",
                    accept = "C-y",
                    next = "<M-]>",
                    prev = "<M-[>",
                    dismiss = "<C-]>",
                },
            },
            panel = {
                enabled = true,
                auto_refresh = true,
                keymap = {
                    open = "<M-CR>",
                    jump_prev = "[[",
                    jump_next = "]]",
                    accept = "<CR>",
                    refresh = "gr",
                },
            },
            filetypes = {
                ["*"] = true,
            },
            server_opts_overrides = {},
        },
    },
}
