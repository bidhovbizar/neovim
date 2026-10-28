return {
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        --event = "VeryLazy", -- Uncommenting this will make copilotchat always load immediately after nvim starts
        --event = "InsertEnter", -- This will load copilotchat when you enter insert mode for the first time
        cmd = { "CopilotChat", "CopilotChatSave", "CopilotChatLoad", "CopilotChatLoadTracked", "CopilotChatCommit", "CopilotChatExplain", "CopilotChatReview", "CopilotChatFix", "CopilotChatOptimize", "CopilotChatDocs", "CopilotChatTests" },
        dependencies = {
            { "zbirenbaum/copilot.lua" }, -- or zbirenbaum/copilot.lua or github/copilot.vim
            { "nvim-lua/plenary.nvim" },  -- for curl, log and async functions
            { "MeanderingProgrammer/render-markdown.nvim" }, -- Markdown rendering configured centrally
        },
        --build = "make tiktoken",                            -- Only on MacOS or Linux
        opts = {
            -- Disables copilotchat default autocomplete and suggestion to avoid conflicts from blink.cmp
            chat_autocomplete = false,
            -- Set model to use for Copilot Chat first find which model you wish to use.
            -- You can find it by starting copilotchat and then pressing `$`.
            --
            model = 'gpt-5.6-sol', -- This is costliest
            --model = 'claude-sonnet-5', -- This is thinking model which is slow
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
                --'#gitdiff',-- commented as @copilot already has that  -- Takes git diff changes in workspace and put in chat
                '@copilot',  -- Gives the tool capability to use copilot tool that contains a lot of smaller tools
                
                },
            window = {
                layout = 'vertical', -- can be 'horizontal' or 'vertical'
                width = 0.4,         -- 40% of screen width
            },
            -- Custom prompts
            prompts = {
                commentonchanges = {
                    prompt = "Check if we discussed any code changes earlier in this conversation. If yes, compare my current buffer against what we discussed and evaluate my implementation. If no prior discussion exists, analyze the current buffer for syntax errors, bugs, or potential issues. If the buffer looks good, check #gitdiff for recent unstaged changes and review those. If this is the start of our conversation with no context available, let me know and offer to help review or discuss any code I'd like to work on. Always provide actionable feedback.",
                    description = "Review current buffer for issues and verify against prior discussion",
                },
                reviewgitchanges = {
                    prompt = "#gitdiff\n\nPlease review my unstaged git changes. Analyze what I've modified, check for any issues, suggest improvements, and let me know if the changes look good overall.",
                    description = "Review all unstaged git changes across the repo",
                },
                ciscocodereview = {
                    prompt = "Review the following code for improvements and best practices.",
                    system_prompt = require("prompts.ciscopythoncodereview").prompt, -- Ensure that your prompt is defined in lua/prompts/copilotprompts.lua
                    description = "Cisco Code Review",
                },
            },
        },
        -- Saving the copilot chat session on exit at ~/.local/share/nvim/copilotchat_history/.
        -- Enabling load option to load the needed session on start up.
        config = function(_, opts)
            require("CopilotChat").setup(opts)

            local group = vim.api.nvim_create_augroup("CopilotChatAutoSave", {
                clear = true,
            })

            local last_file = vim.api.nvim_buf_get_name(0)
            local loaded_session
            local history_path = vim.fs.normalize(
                opts.history_path
                    or (vim.fn.stdpath("data") .. "/copilotchat_history")
            )

            local function session_path(name)
                return vim.fs.joinpath(history_path, name .. ".json")
            end

            local function load_session(name)
                if not name or name == "" then
                    return
                end

                name = vim.fs.basename(name):gsub("%.json$", "")
                if vim.fn.filereadable(session_path(name)) ~= 1 then
                    vim.notify(
                        "CopilotChat session not found: " .. name,
                        vim.log.levels.ERROR
                    )
                    return
                end

                require("CopilotChat").load(name, history_path)
                loaded_session = name
            end

            local function list_sessions()
                local sessions = {}
                local uv = vim.uv or vim.loop

                if vim.fn.isdirectory(history_path) == 1 then
                    for name, entry_type in vim.fs.dir(history_path) do
                        if entry_type == "file" and name:sub(-5) == ".json" then
                            local session_name = name:sub(1, -6)
                            local stat = uv.fs_stat(session_path(session_name))
                            local mtime = stat and stat.mtime or {}

                            table.insert(sessions, {
                                name = session_name,
                                sec = mtime.sec or 0,
                                nsec = mtime.nsec or 0,
                            })
                        end
                    end
                end

                table.sort(sessions, function(a, b)
                    if a.sec == b.sec then
                        if a.nsec == b.nsec then
                            return a.name > b.name
                        end

                        return a.nsec > b.nsec
                    end

                    return a.sec > b.sec
                end)

                return vim.tbl_map(function(session)
                    return session.name
                end, sessions)
            end

            vim.api.nvim_create_user_command("CopilotChatLoadTracked", function(command)
                if command.args ~= "" then
                    load_session(command.args)
                    return
                end

                local sessions = list_sessions()
                if vim.tbl_isempty(sessions) then
                    vim.notify("No saved CopilotChat sessions found", vim.log.levels.INFO)
                    return
                end

                vim.ui.select(sessions, {
                    prompt = "Load CopilotChat session:",
                }, load_session)
            end, {
                nargs = "?",
                force = true,
                complete = function(arg_lead)
                    return vim.tbl_filter(function(name)
                        return vim.startswith(name, arg_lead)
                    end, list_sessions())
                end,
            })

            vim.api.nvim_create_autocmd("BufEnter", {
                group = group,
                callback = function(args)
                    local name = vim.api.nvim_buf_get_name(args.buf)
                    local buftype = vim.bo[args.buf].buftype

                    if buftype == "" and name ~= "" then
                        last_file = name
                    end
                end,
            })

            vim.api.nvim_create_autocmd("VimLeavePre", {
                group = group,
                once = true,
                callback = function()
                    local project = vim.fs.basename(vim.fn.getcwd())
                    local filename = last_file ~= ""
                            and vim.fs.basename(last_file)
                        or "no-file"

                    project = project:gsub("[^%w._-]", "_")
                    filename = filename:gsub("[^%w._-]", "_")

                    local session_name = string.format(
                        "%s-%s-%s-%s",
                        project,
                        filename,
                        os.date("%Y%m%d-%H%M%S"),
                        vim.fn.getpid()
                    )

                    local chat = require("CopilotChat")
                    local saved = pcall(chat.save, session_name, history_path)
                    local new_path = session_path(session_name)

                    if saved
                        and vim.fn.filereadable(new_path) == 1
                        and loaded_session
                        and loaded_session ~= session_name
                    then
                        vim.fn.delete(session_path(loaded_session))
                    end
                end,
            })
        end,
        keys = {
            { "<leader>cc", "<cmd>CopilotChat<CR>", mode = { "n", "v" }, desc = "Chat with Copilot" },
            { "<leader>cx", "<cmd>delmarks < ><CR>", mode = "n", desc = "Clear selection marks in buffer" },
            { "<leader>cg", "<cmd>CopilotChat /reviewgitchanges<CR>", mode = "n", desc = "Review Git Changes" },
            { "<leader>co", "<cmd>CopilotChat /commentonchanges<CR>", mode = "n", desc = "Comment on Changes" },
            { "<leader>cs", "<cmd>CopilotChatSave<CR>", mode = "n", desc = "Save Copilot Chat" },
            { "<leader>cl", "<cmd>CopilotChatLoadTracked<CR>", mode = "n", desc = "Load Copilot Chat" },
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
