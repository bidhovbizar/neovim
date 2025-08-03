return {
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        event = "VeryLazy",
        dependencies = {
            { "zbirenbaum/copilot.lua" },                   -- or zbirenbaum/copilot.lua or github/copilot.vim
            { "nvim-lua/plenary.nvim" }, -- for curl, log and async functions
        },
        build = "make tiktoken",                            -- Only on MacOS or Linux
        opts = {
            model = 'claude-3.7-sonnet',
            -- auto_insert_mode = true, -- This directly move us to insert mode after the chat window opens but also keeps it there after the response
            window = {
                layout = 'vertical', -- can be 'horizontal' or 'vertical'
                width = 0.4,         -- 40% of screen width
            },
            -- Add agents configuration here
            agents = {
                code_review = {
                    description = "Review code for improvements",
                },
                explain = {
                    description = "Explain code functionality",
                },
                fix = {
                    description = "Fix code issues",
                },
                optimize = {
                    description = "Optimize code performance",
                },
                test = {
                    description = "Generate unit tests",
                },
            },
            prompts = {
                ciscocodereview= {
                    prompt = "Review the following code for improvements and best practices.",
                    system_prompt = require("prompts.copilotprompts").prompt,  -- Ensure that your prompt is defined in lua/prompts/copilotprompts.lua
                    description = "Cisco Code Review",
                },
            },
        },
        keys = {
            { "<leader>cc", "<cmd>CopilotChat<CR>",         desc = "Chat with Copilot" },
            { "<leader>ce", "<cmd>CopilotChatExplain<CR>",  mode = "v",                desc = "Explain Code" },
            { "<leader>cr", "<cmd>CopilotChatReview<CR>",   mode = "v",                desc = "Review Code" },
            { "<leader>cf", "<cmd>CopilotChatFix<CR>",      mode = "v",                desc = "Fix Code Issues" },
            { "<leader>co", "<cmd>CopilotChatOptimize<CR>", mode = "v",                desc = "Optimize Code" },
            { "<leader>cD", "<cmd>CopilotChatDocs<CR>",     mode = "v",                desc = "Generate Docs" },
            { "<leader>ct", "<cmd>CopilotChatTests<CR>",    mode = "v",                desc = "Generate Tests" },
            { "<leader>cm", "<cmd>CopilotChatCommit<CR>",   mode = { "n", "v"},        desc = "Generate Commit Message" },
        },
        -- Entering any of the following command will initiate Copilot in neovim
        --cmd = {
        --    "CopilotChat",
        --}
    },
}
