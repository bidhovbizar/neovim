local ai_chat_filetypes = {
    ["copilot-chat"] = true,
    codecompanion = true,
    codecompanion_input = true,
    AvanteInput = true,
    AvantePromptInput = true,
}
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
                    accept = "<M-y>",
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
            should_attach = function(bufnr, _)
                if ai_chat_filetypes[vim.bo[bufnr].filetype] then
                    return true
                end

                return vim.bo[bufnr].buflisted and vim.bo[bufnr].buftype == ""
            end,

            server_opts_overrides = {},
        },
    },
}
