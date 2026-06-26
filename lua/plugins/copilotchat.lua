return {
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        --event = "VeryLazy", -- Uncommenting this will make copilotchat always load immediately after nvim starts
        --event = "InsertEnter", -- This will load copilotchat when you enter insert mode for the first time
        cmd = { "CopilotChat", "CopilotChatCommit", "CopilotChatExplain", "CopilotChatReview", "CopilotChatFix", "CopilotChatOptimize", "CopilotChatDocs", "CopilotChatTests" },
        dependencies = {
            { "zbirenbaum/copilot.lua" }, -- or zbirenbaum/copilot.lua or github/copilot.vim
            { "nvim-lua/plenary.nvim" },  -- for curl, log and async functions
        },
        --build = "make tiktoken",                            -- Only on MacOS or Linux
        opts = {
            -- Disables copilotchat default autocomplete and suggestion to avoid conflicts from blink.cmp
            chat_autocomplete = false,
            -- Set model to use for Copilot Chat first find which model you wish to use.
            -- You can find it by starting copilotchat and then pressing `$`.
            --
            model = 'claude-opus-4.5', -- This is costliest
            --model = 'claude-sonnet-4', -- This is thinking model which is slow
            --model = 'gpt-4o-mini',      -- This is for fast responses
            -- auto_insert_mode = true, -- This directly move us to insert mode after the chat window opens but also keeps it there after the response
            -- Automatically include current buffer as context, All sticky context options in CopilotChat:
            --  Context             | Description |
            ------------------------|-------------|
            -- `#buffer`            | Current buffer content |
            -- `#buffers`           | All open buffers |
            -- `#file:path/to/file` | Specific file content |
            -- `#files`             | Opens file picker to select files |
            -- `#gitdiff`           | Unstaged git changes |
            -- `#git:staged`        | Staged git changes |
            -- `#url:https://...`   | Content from a URL |
            -- `#register:name`     | Content from a Neovim register |
            -- `#quickfix`          | Quickfix list contents |
            -- `#diagnostics`       | LSP diagnostics |
            -- `#system`            | System information |
            sticky = {
                '#buffer',  -- Always gives current buffer as context while talking
                '#gitdiff', -- If you have git changes in the current buffer, it will give that as context
                '@copilot',  -- Gives the tool capability to use copilot tool that contains a lot of smaller tools
                },
            window = {
                layout = 'vertical', -- can be 'horizontal' or 'vertical'
                width = 0.4,         -- 40% of screen width
            },
            -- Custom prompts
            prompts = {
                commentonchanges= {
                    prompt = "I made some changes to this code based on our previous discussion. Please review what I've done compared to what we discussed - not git changes, just evaluate if my implementation looks correct and matches our conversation. Any feedback?",
                    description = "Comment on changes made from our discussion",
                },
                reviewgitchanges= {
                    prompt = "#gitdiff\n\nPlease review my unstaged git changes. Analyze what I've modified, check for any issues, suggest improvements, and let me know if the changes look good overall.",
                    description = "Review unstaged git changes",
                },
                ciscocodereview = {
                    prompt = "Review the following code for improvements and best practices.",
                    system_prompt = require("prompts.ciscopythoncodereview").prompt, -- Ensure that your prompt is defined in lua/prompts/copilotprompts.lua
                    description = "Cisco Code Review",
                },
            },
        },
        keys = {
            { "<leader>cc", "<cmd>CopilotChat<CR>", mode = { "n", "v" }, desc = "Chat with Copilot" },
            { "<leader>cx", "<cmd>delmarks < ><CR>", mode = "n", desc = "Clear selection marks in buffer" },
            { "<leader>cg", "<cmd>CopilotChat /reviewgitchanges<CR>", mode = "n", desc = "Review Git Changes" },
            { "<leader>co", "<cmd>CopilotChat /commentonchanges<CR>", mode = "n", desc = "Comment on Changes" },
            { "<leader>cs", "<cmd>CopilotChatSave<CR>", mode = "n", desc = "Save Copilot Chat" },
            { "<leader>cl", "<cmd>CopilotChatLoad<CR>", mode = "n", desc = "Load Copilot Chat" },
            --{ "<leader>cm", "<cmd>CopilotChatCommit<CR>",   mode = { "n", "v"},   desc = "Generate Commit Message" },
            --{ "<leader>ce", "<cmd>CopilotChatExplain<CR>",  mode = "v",           desc = "Explain Code" },
            --{ "<leader>cr", "<cmd>CopilotChatReview<CR>",   mode = "v",           desc = "Review Code" },
            --{ "<leader>cf", "<cmd>CopilotChatFix<CR>",      mode = "v",           desc = "Fix Code Issues" },
            --{ "<leader>co", "<cmd>CopilotChatOptimize<CR>", mode = "v",           desc = "Optimize Code" },
            --{ "<leader>cD", "<cmd>CopilotChatDocs<CR>",     mode = "v",           desc = "Generate Docs" },
            --{ "<leader>ct", "<cmd>CopilotChatTests<CR>",    mode = "v",           desc = "Generate Tests" },
        },
    },
}
