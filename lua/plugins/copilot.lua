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
        -- NES is horrible while suggesting next code change, the suggestion even have error so disabling it
        --dependencies = {
        --    {
        --        "copilotlsp-nvim/copilot-lsp",
        --        init = function()
        --            vim.g.copilot_nes_debounce = 500
        --        end,
        --    },
        --},
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
                    accept = "<M-y>", -- This is by default kept for snacks to remember the keymap
                    accept_word = "<M-w>",
                    next = "<M-]>",
                    prev = "<M-[>",
                    dismiss = "<M-d>", -- Tried changing to <Esc> but it loses other abilities
                },
            },
            -- Disabling NES commands as they are not useful and sometimes cause issues with suggestions
            --nes = {
            --    enabled = true,
            --    auto_trigger = true,
            --    keymap = {
            --        accept_and_goto = "<M-CR>",
            --        --accept = "<M-n>",
            --        dismiss = "<M-d>",
            --    },
            --},
            panel = {
                enabled = true,
                auto_refresh = true,
                keymap = {
                    open = "<M-o>", -- In copilotchat it opens a list of all possibilities and you can select one to insert into the buffer
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

            server_opts_overrides = {
                settings = {
                    advanced = {
                        inlineSuggestCount = 2,
                        listCount = 5,
                    },
                },

            },
        },
    },
}
