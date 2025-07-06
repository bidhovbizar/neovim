return {
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        tag = "v3.9.1",
        --tag = "v3.7.0",
        event = "VeryLazy",
        dependencies = {
            { "zbirenbaum/copilot.lua" },                   -- or zbirenbaum/copilot.lua or github/copilot.vim
            { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
        },
        build = "make tiktoken",                            -- Only on MacOS or Linux
        opts = {
            window = {
                layout = 'vertical', -- can be 'horizontal' or 'vertical'
                width = 0.4,         -- 40% of screen width
            },
            -- Add agents configuration here
            agents = {
                {
                    name = "code_review",
                    description = "Review code for improvements",
                },
                {
                    name = "explain",
                    description = "Explain code functionality",
                },
                {
                    name = "fix",
                    description = "Fix code issues",
                },
                {
                    name = "optimize",
                    description = "Optimize code performance",
                },
                {
                    name = "test",
                    description = "Generate unit tests",
                },
            },
        },
        keys = {
            { "<leader>cc", "<cmd>CopilotChat<CR>",         mode = "n", desc = "Chat with Copilot" },
            { "<leader>cS", "<cmd>CopilotChatStatus<cr>",   mode = "n", desc = "Copilot Chat Status" },
            { "<leader>ce", "<cmd>CopilotChatExplain<CR>",  mode = "v", desc = "Explain Code" },
            { "<leader>cr", "<cmd>CopilotChatReview<CR>",   mode = "v", desc = "Review Code" },
            { "<leader>cf", "<cmd>CopilotChatFix<CR>",      mode = "v", desc = "Fix Code Issues" },
            { "<leader>co", "<cmd>CopilotChatOptimize<CR>", mode = "v", desc = "Optimize Code" },
            { "<leader>cd", "<cmd>CopilotChatDocs<CR>",     mode = "v", desc = "Generate Docs" },
            { "<leader>ct", "<cmd>CopilotChatTests<CR>",    mode = "v", desc = "Generate Tests" },
            { "<leader>cm", "<cmd>CopilotChatCommit<CR>",   mode = "n", desc = "Generate Commit Message" },
            { "<leader>cs", "<cmd>CopilotChatCommit<CR>",   mode = "v", desc = "Generate Commit for Selection" },
            { "<leader>cL", "<cmd>CopilotChatLog<cr>",      mode = "v", desc = "Copilot Chat Log" },
            { "<leader>ca", "<cmd>CopilotChatAgents<cr>",   mode = "n", desc = "Copilot Chat Agents" },
        },
        -- Entering any of the following command will initiate Copilot in neovim
        --cmd = {
        --    "CopilotChat",
        --}
    },
}
