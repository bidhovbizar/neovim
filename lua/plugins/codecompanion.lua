local function run_prompt_in_chat(alias)
    local codecompanion = require("codecompanion")
    local chat = codecompanion.buf_get_chat(0) or codecompanion.last_chat()

    if not chat then
        chat = codecompanion.chat()
    end

    if not chat then
        return vim.notify("CodeCompanion: could not open chat", vim.log.levels.WARN)
    end

    local context = require("codecompanion.utils.context").get(vim.api.nvim_get_current_buf())
    local prompt = require("codecompanion.action_palette").resolve_from_alias(alias, context)

    if not prompt then
        return vim.notify("CodeCompanion: prompt not found: " .. alias, vim.log.levels.WARN)
    end

    require("codecompanion.interactions.chat.slash_commands").run({
        label = "/" .. alias,
        type = "slash_command",
        from_prompt_library = true,
        config = prompt,
        context = context,
    }, chat)

    chat.ui:open()

    if prompt.opts and prompt.opts.auto_submit then
        chat:submit()
    end
end

-- Per-adapter approval for a new chat. Change it later in the buffer with `gty`.
local acp_approval_mode = {
    cursor_cli = "auto",
    codex = "auto",
}

-- Last `gty` choice per adapter, restored when resuming (not when opening a new chat).
local last_acp_approval_mode = {}

local function remember_approval(chat)
    if not chat or not chat.adapter or chat.adapter.type ~= "acp" then
        return
    end
    last_acp_approval_mode[chat.adapter.name] =
        require("codecompanion.interactions.chat.tools.approvals"):get_mode(chat.bufnr)
end

local function find_chat(adapter_name)
    -- Do not call last_chat() first: if :q unloaded the buffer, last_chat() destroys the session.
    local found
    for _, entry in ipairs(require("codecompanion").buf_get_chat()) do
        local chat = entry.chat
        if chat.adapter and chat.adapter.name == adapter_name and vim.api.nvim_buf_is_valid(chat.bufnr) then
            found = chat
        end
    end
    return found
end

local function acp_session_ready(chat)
    return chat
        and chat.adapter
        and chat.adapter.type == "acp"
        and chat.acp_connection
        and chat.acp_connection.session_id
end

-- One Cursor ACP (`agent acp`) per user: the first nvim that starts it keeps it
-- until that nvim exits. A second nvim skips pre-warm and will not start another.
-- Scoped by hostname so NFS-shared home directories between Ubuntu/RHEL do not cross-lock.
local cursor_acp_lock = {
    dir = vim.fn.stdpath("cache") .. "/codecompanion-cursor-acp-" .. (vim.uv.os_gethostname() or "default") .. ".lock",
    held = false,
}

local function proc_starttime(pid)
    local f = io.open("/proc/" .. pid .. "/stat", "r")
    if not f then
        return nil
    end
    local line = f:read("*l")
    f:close()
    if not line then
        return nil
    end
    -- /proc/pid/stat: field 22 is starttime. Field 2 is comm in parentheses.
    local rest = line:match("%)%s+(.+)$")
    if not rest then
        return nil
    end
    local fields = vim.split(rest, " ", { plain = true, trimempty = false })
    return fields[20]
end

local function cursor_acp_self()
    local pid = vim.fn.getpid()
    return {
        pid = pid,
        starttime = proc_starttime(pid),
        cwd = vim.fn.getcwd(),
        time = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    }
end

local function read_cursor_acp_holder()
    local path = cursor_acp_lock.dir .. "/holder.json"
    local ok, lines = pcall(vim.fn.readfile, path)
    if not ok or not lines or not lines[1] then
        return nil
    end
    local success, holder = pcall(vim.json.decode, lines[1])
    if success and type(holder) == "table" then
        return holder
    end
    return nil
end

local function holder_is_alive(holder)
    if not holder or not holder.pid then
        return false
    end
    if vim.uv.kill(holder.pid, 0) ~= 0 then
        return false
    end
    if holder.starttime then
        return tostring(proc_starttime(holder.pid)) == tostring(holder.starttime)
    end
    return true
end

local function holder_is_self(holder)
    if not holder then
        return false
    end
    local self = cursor_acp_self()
    return holder.pid == self.pid and (not holder.starttime or holder.starttime == self.starttime)
end

local function release_cursor_acp_lock()
    if not cursor_acp_lock.held then
        return
    end
    cursor_acp_lock.held = false
    vim.fn.delete(cursor_acp_lock.dir, "rf")
end

-- Returns true if this nvim owns (or just acquired) the Cursor ACP lock.
local function claim_cursor_acp()
    if cursor_acp_lock.held then
        return true
    end

    local holder = read_cursor_acp_holder()
    if holder_is_self(holder) then
        cursor_acp_lock.held = true
        return true
    end

    if holder_is_alive(holder) then
        return false, holder
    end

    -- Stale lock from a crashed nvim, or no lock yet.
    if vim.fn.isdirectory(cursor_acp_lock.dir) == 1 then
        vim.fn.delete(cursor_acp_lock.dir, "rf")
    end

    local mkdir_ok = vim.uv.fs_mkdir(cursor_acp_lock.dir, 448) -- 0700
    if not mkdir_ok then
        holder = read_cursor_acp_holder()
        if holder_is_self(holder) then
            cursor_acp_lock.held = true
            return true
        end
        if holder_is_alive(holder) then
            return false, holder
        end
        return false, holder
    end

    local self = cursor_acp_self()
    vim.fn.writefile({ vim.json.encode(self) }, cursor_acp_lock.dir .. "/holder.json")
    cursor_acp_lock.held = true
    return true
end

local function format_cursor_acp_busy(holder)
    local where = holder and holder.cwd or "another Neovim"
    local pid = holder and holder.pid
    if pid then
        return string.format(
            "CodeCompanion: Cursor ACP is already in use by nvim pid %s (%s). Close that instance to use it here.",
            pid,
            where
        )
    end
    return "CodeCompanion: Cursor ACP is already in use by another Neovim. Close that instance to use it here."
end

local function requested_chat_adapter(args)
    args = args or {}
    local adapter = args.adapter
        or (args.params and args.params.adapter)
        or require("codecompanion.config").interactions.chat.adapter
    if type(adapter) == "table" then
        return adapter.name
    end
    return adapter
end

local function toggle_chat(adapter_name, formatted_name)
    local codecompanion = require("codecompanion")
    local chat = find_chat(adapter_name)
    if not chat then
        return codecompanion.chat({
            params = { adapter = adapter_name },
            approval_mode = acp_approval_mode[adapter_name] or "ask",
        })
    end
    if chat.ui:is_visible() then
        remember_approval(chat)
        vim.notify("CodeCompanion: hiding " .. formatted_name .. " chat", vim.log.levels.INFO)
        return chat.ui:hide()
    end
    vim.notify("CodeCompanion: reopening " .. formatted_name .. " chat", vim.log.levels.INFO)
    return codecompanion.restore(chat.bufnr)
end

-- Open the ACP session options picker (Agent/Plan/Ask, model, reasoning, ...) for the current chat.
local function acp_session_options()
    local codecompanion = require("codecompanion")
    local chat = codecompanion.buf_get_chat(0) or codecompanion.last_chat()
    if not chat or not chat.adapter or chat.adapter.type ~= "acp" then
        return vim.notify("CodeCompanion: open an ACP chat first (<leader>cc or <leader>cC)", vim.log.levels.WARN)
    end
    chat.ui:open()
    require("codecompanion.interactions.chat.slash_commands").run({
        label = "/acp_session_options",
        type = "slash_command",
        config = require("codecompanion.config").interactions.chat.slash_commands["acp_session_options"],
    }, chat)
end

local function resume_acp_chat(adapter_name)
    local codecompanion = require("codecompanion")
    -- Prefer the current chat buffer; do not call last_chat() (it can close an unloaded session).
    local current = codecompanion.buf_get_chat(0)
    remember_approval(current)
    if not adapter_name then
        if current and current.adapter and current.adapter.type == "acp" then
            adapter_name = current.adapter.name
        else
            adapter_name = "cursor_cli"
        end
    end

    local formatted = adapter_name == "codex" and "Codex" or "Cursor"

    local function run_resume(chat)
        if not chat then
            return vim.notify("CodeCompanion: could not open " .. formatted .. " chat", vim.log.levels.WARN)
        end
        if chat.ui and not chat.ui:is_visible() then
            codecompanion.restore(chat.bufnr)
        else
            chat.ui:open()
        end
        -- Builtin /resume refuses a chat that already has messages. Load on this
        -- connection anyway; picking a session replaces the buffer, cancel keeps it.
        if not chat.acp_connection then
            return require("codecompanion.interactions.chat.slash_commands").new():execute({
                label = "/resume",
                type = "slash_command",
                config = require("codecompanion.config").interactions.chat.slash_commands.resume,
            }, chat)
        end
        local listed = chat.acp_connection:session_list({ max_sessions = 500 })
        if #listed == 0 then
            return vim.notify("CodeCompanion: no previous sessions found", vim.log.levels.INFO)
        end
        local utils = require("codecompanion.utils")
        local choices, session_map = {}, {}
        for i, session in ipairs(listed) do
            local parts = {}
            if session.updatedAt then
                local ts = utils.timestamp_from_iso(session.updatedAt)
                if ts then
                    table.insert(parts, "(" .. utils.make_relative(ts) .. ")")
                end
            end
            table.insert(parts, session.title or session.sessionId)
            choices[i] = table.concat(parts, " ")
            session_map[i] = session
        end
        vim.ui.select(choices, {
            prompt = "Resume Session",
            kind = "codecompanion.nvim",
        }, function(_, idx)
            if not idx then
                return
            end
            local selected = session_map[idx]
            local updates = {}
            local ok = chat.acp_connection:load_session(selected.sessionId, {
                on_session_update = function(update)
                    table.insert(updates, update)
                end,
            })
            if not ok then
                return vim.notify("Failed to load session", vim.log.levels.ERROR)
            end
            require("codecompanion.interactions.chat.acp.commands").link_buffer_to_session(
                chat.bufnr,
                chat.acp_connection.session_id
            )
            require("codecompanion.interactions.chat.acp.render").restore_session(chat, updates)
            if selected.title then
                chat:set_title(selected.title)
            end
            vim.notify("Resumed session: " .. (selected.title or selected.sessionId), vim.log.levels.INFO)
        end)
    end

    local function wait_then_resume(chat)
        local group = vim.api.nvim_create_augroup("BidhovCodeCompanionResume", { clear = true })
        local resumed = false

        -- Wait until session/new finishes so /resume does not race it.
        vim.api.nvim_create_autocmd("User", {
            group = group,
            pattern = "CodeCompanionACPSessionPost",
            callback = function()
                if not acp_session_ready(chat) then
                    return
                end
                resumed = true
                pcall(vim.api.nvim_del_augroup_by_id, group)
                run_resume(chat)
            end,
        })

        vim.defer_fn(function()
            if not resumed then
                pcall(vim.api.nvim_del_augroup_by_id, group)
                vim.notify("CodeCompanion: ACP session was not ready for /resume", vim.log.levels.WARN)
            end
        end, 20000)
    end

    local existing = find_chat(adapter_name)
    if existing then
        if acp_session_ready(existing) then
            return run_resume(existing)
        end
        if existing.ui and not existing.ui:is_visible() then
            codecompanion.restore(existing.bufnr)
        end
        return wait_then_resume(existing)
    end

    -- No connected chat for this adapter: open one, then run /resume.
    local chat = codecompanion.chat({
        params = { adapter = adapter_name },
        approval_mode = last_acp_approval_mode[adapter_name]
            or acp_approval_mode[adapter_name]
            or "ask",
    })
    if not chat then
        return vim.notify("CodeCompanion: could not open " .. formatted .. " chat", vim.log.levels.WARN)
    end
    wait_then_resume(chat)
end

return {
    "olimorris/codecompanion.nvim",
    -- v20+ requires Neovim 0.12+; stay on the last 19.x release for Neovim 0.11.
    version = "^19.0.0",
    dependencies = {
        { "nvim-lua/plenary.nvim" },
        {
            "nvim-treesitter/nvim-treesitter",
            lazy = false,
            build = ":TSUpdate",
        },
        { "MeanderingProgrammer/render-markdown.nvim" }, -- Markdown rendering configured centrally
        -- Mark view is heavier and gives more decorations but is not as stable as render-markdown
        --{
        --    "OXY2DEV/markview.nvim",
        --    lazy = false,
        --    opts = {
        --        preview = {
        --            filetypes = { "markdown", "codecompanion" },
        --            ignore_buftypes = {},
        --        },
        --    },
        --},
        {
            "echasnovski/mini.diff",
            config = function()
                -- Load the mini.diff module
                local diff = require("mini.diff")
                -- Configure mini.diff with no default source
                -- This disables automatic diff detection, allowing manual control
                diff.setup({
                    source = diff.gen_source.none(),
                })
            end,
        },
    },
    opts = {
        adapters = {
            http = {
                copilot = function()
                    return require("codecompanion.adapters").extend("copilot", {
                        opts = {
                            show_model_choices = true,
                        },
                    })
                end,
            },
            acp = {
                codex = function()
                    return require("codecompanion.adapters").extend("codex", {
                        defaults = {
                            -- This `codex-acp` advertises chat-gpt (not chatgpt).
                            auth_method = "chat-gpt",
                            -- press `ga` to list models the agent currently offers, then pick one.
                            -- `/acp_session_options` can also change the model mid-session.
                            -- Uncomment to chose a specific model you get from ga
                            -- session_config_options = {
                            --     model = "gpt-5.6-sol",
                            -- },
                        },
                    })
                end,
            },
        },
        -- `strategies` was renamed to `interactions` in CodeCompanion v18.0.0.
        -- Do not keep both keys: if `strategies` is present, it replaces this table.
        interactions = {
            chat = {
                roles = {
                    user = "Bidhov",
                    llm = function(adapter)
                        return "CodeCompanion (" .. adapter.formatted_name .. ")"
                    end,
                },
                -- Uncomment the following for copilot chat adapter
                --adapter = {
                --    -- Uncomment the adapter you want
                --    -- Copilot
                --    name = "copilot",
                --    model = "gpt-5.6-sol",

                --    --Codex
                --    --name = "codex",
                --},
                -- Default chat is Cursor. Press `ga` in the chat buffer to list
                -- models (and switch adapter). Do not pin a model here.
                adapter = "cursor_cli",
                keymaps = {
                    options = {
                        modes = { n = "g?" }, -- Change from ? to g?
                    },
                },
                opts = {
                    completion_provider = "blink", -- blink|cmp|coc|default
                },
                slash_commands = {
                    ["file"] = {
                        --callback = "interactions.chat.slash_commands.file",
                        description = "Select a file using Telescope",
                        opts = {
                            provider = "telescope", -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks"
                            contains_code = true,
                        },
                    },
                },
            },
            inline = {
                adapter = {
                    -- Keeping copilot for inline as codex and cursor is an ACP adapter; inline interactions require HTTP.
                    name = "copilot",
                    -- Commenting models it takes default value
                    --model = "gpt-5.6-sol",
                },
            },
            -- Used by the Auto-mode tools judge. Chat titles stay off unless
            -- background.chat.opts.enabled is set true. Needs an HTTP adapter.
            background = {
                adapter = {
                    name = "copilot",
                    -- Commenting models it takes default value
                    -- model = "gpt-5.6-sol",
                },
            },
            shared = {
                editor_context = {
                    ["buffer"] = {
                        opts = {
                            -- Used by #{buffer}. Accepted values:
                            --   "all"  send the whole buffer (works without git)
                            --   "diff" send only changes since it was last shared
                            -- Override in a message with #{buffer}{all} or #{buffer}{diff}.
                            default_params = "all",
                        },
                    },
                },
            },
        },
        prompt_library = {
            ["Comment On Changes"] = {
                interaction = "chat",
                description = "Review current buffer for issues and verify against prior discussion",
                opts = {
                    -- To force use of an adapter uncomment
                    --adapter = {
                    --    name = "codex",  -- Use Codex: "codex" or Cursor: "cursor_cli"
                    --},
                    alias = "commentonchanges",
                    auto_submit = true,
                    is_slash_cmd = true,
                },
                prompts = {
                    {
                        role = "user",
                        content = "#{buffer}\n\nCheck if we discussed any code changes earlier in this conversation. If yes, compare my current buffer against what we discussed and evaluate my implementation. If no prior discussion exists, analyze the current buffer for syntax errors, bugs, or potential issues. If the buffer looks good, check #{diff} for recent git changes and review those. If this is the start of our conversation with no context available, let me know and offer to help review or discuss any code I'd like to work on. Always provide actionable feedback.",
                    },
                },
            },
            ["Review Git Changes"] = {
                interaction = "chat",
                description = "Review all git changes across the repo",
                opts = {
                    -- To force use of an adapter uncomment
                    --adapter = {
                    --    name = "codex",  -- Use Codex: "codex" or Cursor: "cursor_cli"
                    --},
                    alias = "reviewgitchanges",
                    auto_submit = true,
                    is_slash_cmd = true,
                },
                prompts = {
                    {
                        role = "user",
                        content = "#{diff}\n\nReview all my git changes across the entire repository:\n1. Analyze what I've modified in each file\n2. Check for consistency across files\n3. Look for any issues, bugs, or improvements\n4. Confirm the changes work well together as a whole\n\nThis is my final review before committing - let me know if everything looks good or what needs attention.",
                    },
                },
            },
            ["Cisco Code Review"] = {
                interaction = "chat",
                description = "Cisco Code Review",
                opts = {
                    -- To force use of an adapter uncomment
                    --adapter = {
                    --    name = "codex",  -- Use Codex: "codex" or Cursor: "cursor_cli"
                    --},
                    modes = { "v" },
                    alias = "ciscocodereview",
                    auto_submit = true,
                    is_slash_cmd = true,
                },
                prompts = {
                    {
                        role = "system",
                        content = function()
                            local ok, prompt = pcall(function()
                                return require("prompts.ciscopythoncodereview").prompt
                            end)
                            return ok and prompt or "You are a code reviewer. Review the code for improvements and best practices."
                        end,
                    },
                    {
                        role = "user",
                        content = function(context)
                            return string.format(
                                "Review the following code for improvements and best practices:\n\n```%s\n%s\n```",
                                context.filetype or "",
                                context.code or ""
                            )
                        end,
                    },
                },
            },
        },
        display = {
            chat = {
                intro_message = "Welcome to CodeCompanion ✨! g? help | ga model | <leader>cm mode (Agent/Plan/Ask) | gty approval (Ask/Auto/YOLO)",
                separator = "-",              -- The separator between the different messages in the chat buffer
                show_context = true,          -- Show context (from slash commands and variables) in the chat buffer
                show_header_separator = true, -- Show header separators in the chat buffer? Set this to false if you're using an external markdown formatting plugin
                show_settings = false,        -- Show LLM settings at the top of the chat buffer including model, temperature, etc.
                show_token_count = false,     -- Show the token count for each response
                show_tools_processing = true, -- Show the loading message when tools are being executed
                start_in_insert_mode = false, -- Open the chat buffer in insert mode?
                auto_scroll = true,           -- Automatically scroll to the bottom of the chat buffer on new messages
                fold_context = false,         -- Fold context messages by default if set to true
                --show_reasoning = false,     -- don't render reasoning at all
                fold_reasoning = true,        -- Fold reasoning messages by default if set to true
                show_tools_processing = false, -- hide the "processing tools" loader line
                icons = {
                    chat_context = "📎 ",
                    chat_fold = " ",
                },

                window = {
                    buflisted = true, -- Keep the chat in the buffer list so :q hides it instead of wiping it
                    layout = "vertical", -- float|vertical|horizontal|buffer
                    position = nil,      -- left|right|top|bottom (nil will default depending on vim.opt.splitright|vim.opt.splitbelow)
                    border = "rounded",
                    height = 0.8,
                    width = 0.45,
                    relative = "editor",
                    full_height = true, -- when set to false, vsplit will be used to open the chat buffer vs. botright/topleft vsplit
                    sticky = true,      -- when set to true and `layout` is not `"buffer"`, the chat buffer will remain opened when switching tabs
                    opts = {
                        breakindent = true,
                        cursorcolumn = false,
                        cursorline = true,
                        foldcolumn = "0",
                        linebreak = true,
                        list = true,
                        numberwidth = 1,
                        signcolumn = "yes",
                        spell = true,
                        wrap = true,
                    },
                },
            },
            action_palette = {
                width = 95,
                height = 10,
                prompt = "Prompt ",                     -- Prompt used for interactive LLM calls
                provider = "snacks",                 -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks".
                opts = {
                    show_default_actions = true,        -- Show the default actions in the action palette?
                    show_default_prompt_library = true, -- Show the default prompt library in the action palette
                    show_preset_prompts = true,
                    show_preset_actions = true,
                    title = "CodeCompanion actions",    -- The title of the action palette
                },
            },
            diff = {
                enabled = true,
                provider = 'mini_diff', -- mini_diff|split|inline

                provider_opts = {
                    -- Options for inline diff provider
                    inline = {
                        layout = "float", -- float|buffer - Where to display the diff

                        diff_signs = {
                            signs = {
                                text = "▌", -- Sign text for normal changes
                                reject = "✗", -- Sign text for rejected changes in super_diff
                                highlight_groups = {
                                    addition = "Question",
                                    deletion = "Visual",
                                    modification = "DiagnosticWarn",
                                },
                            },
                            -- Super Diff options
                            icons = {
                                accepted = " ",
                                rejected = " ",
                            },
                            colors = {
                                accepted = "WildMenu",
                                rejected = "DiagnosticError",
                            },
                        },

                        opts = {
                            context_lines = 3,         -- Number of context lines in hunks
                            dim = 25,                  -- Background dim level for floating diff (0-100, [100 full transparent], only applies when layout = "float")
                            full_width_removed = true, -- Make removed lines span full width
                            show_keymap_hints = true,  -- Show "gda: accept | gdr: reject" hints above diff
                            show_removed = true,       -- Show removed lines as virtual text
                        },
                    },

                    -- Options for the split provider
                    split = {
                        close_chat_at = 240, -- Close an open chat buffer if the total columns of your display are less than...
                        layout = "vertical", -- vertical|horizontal split
                        opts = {
                            "internal",
                            "filler",
                            "closeoff",
                            "algorithm:histogram", -- https://adamj.eu/tech/2024/01/18/git-improve-diff-histogram/
                            "indent-heuristic",    -- https://blog.k-nut.eu/better-git-diffs
                            "followwrap",
                            "linematch:120",
                        },
                    },
                },
            },
        },
    },
    keys = {
        -- Open action palette (works in normal and visual mode)
        { "<leader>cA", "<cmd>CodeCompanionActions<cr>",     mode = { "n", "v" }, desc = "cc list all code actions" },

        -- Toggle chat buffer
        -- In chat:
        -- | `g?` | Options menu (your config moved it from `?`) |
        -- | `ga` | Change adapter and model (lists the agent's models) |
        -- | `gty` | Pick approval mode: Ask, Auto, or YOLO |
        -- | `gtx` | Reset cached approvals |
        -- | `gr` | Regenerate last response |
        -- | `q` | Stop the current request |
        -- | `gm` | Send a follow-up while the agent is streaming |
        -- | `gx` | Clear all messages |
        -- | `<C-c>` | Close the chat |
        -- | `{` / `}` | Previous / next chat |
        -- | `]]` / `[[` | Next / previous header |
        { "<leader>cc", function()
            toggle_chat("cursor_cli", "Cursor")
        end, mode = { "n", "v" }, desc = "cc Toggle Cursor Chat" },
        -- Open chat with Codex explicitly
        { "<leader>cC", function()
            toggle_chat("codex", "Codex")
        end, mode = { "n", "v" }, desc = "cc Chat with Codex" },

        -- Pick the agent's session mode (Agent/Plan/Ask), model, etc. for the current ACP chat
        { "<leader>cm", function()
            acp_session_options()
        end, mode = "n", desc = "cc Session mode/model options" },

        -- Add visual selection to chat
        { "<leader>ca", "<cmd>CodeCompanionChat Add<cr>",    mode = "v",          desc = "cc add to Chat" },

        -- Quick prompts from prompt library
        --{ "<leader>cf", "<cmd>CodeCompanion /fix<cr>",       mode = "v",          desc = "cc Fix Code" },
        --{ "<leader>ce", "<cmd>CodeCompanion /explain<cr>",   mode = "v",          desc = "cc Explain Code" },

        -- Inline assistant
        { "<leader>ci", "<cmd>CodeCompanion<cr>",            mode = { "n", "v" }, desc = "cc Inline Assistant" },

        -- CodeCompanion Help
        { "<leader>ch", "<cmd>help CodeCompanion<cr>",       mode = "n",          desc = "cc Open CodeCompanion Documentation" },

        -- Resume an ACP session on the connected chat (current ACP adapter, else Cursor)
        { "<leader>cr", function()
            resume_acp_chat()
        end, mode = "n", desc = "cc Resume ACP session" },

        -- Custom prompts (using different keys to avoid copilotchat conflicts)
        { "<leader>cg", function()
            run_prompt_in_chat("reviewgitchanges")
        end, mode = "n", desc = "cc Review Git Changes" },
        { "<leader>co", function()
            run_prompt_in_chat("commentonchanges")
        end, mode = "n", desc = "cc Comment on Changes" },

    },
    -- Load at startup (not only on first key) so the Cursor ACP session can warm up in the background.
    event = "VeryLazy",
    config = function(_, opts)
        require("codecompanion").setup(opts)

        -- Expand 'cc' into 'CodeCompanion' in command line
        vim.cmd([[cab cc CodeCompanion]])

        -- Refuse to start a second Cursor ACP from another nvim. Reopening an
        -- existing chat in this instance is always allowed.
        local codecompanion = require("codecompanion")
        local orig_chat = codecompanion.chat
        codecompanion.chat = function(args)
            args = args or {}
            local silent = args._cursor_lock_silent
            args._cursor_lock_silent = nil
            local adapter_name = requested_chat_adapter(args)
            if adapter_name == "cursor_cli" and not find_chat("cursor_cli") then
                local ok, holder = claim_cursor_acp()
                if not ok then
                    if not silent then
                        vim.notify(format_cursor_acp_busy(holder), vim.log.levels.WARN)
                    end
                    return nil
                end
            end
            return orig_chat(args)
        end

        vim.api.nvim_create_autocmd("VimLeavePre", {
            group = vim.api.nvim_create_augroup("BidhovCursorAcpLock", { clear = true }),
            callback = release_cursor_acp_lock,
        })

        -- Pre-warm the default Cursor ACP session so it is ready before you open the chat.
        -- The chat is created hidden; <leader>cc restores it (find_chat reuses it).
        -- Skip silently if another nvim already holds Cursor ACP.
        vim.defer_fn(function()
            if find_chat("cursor_cli") then
                return
            end
            local ok = claim_cursor_acp()
            if not ok then
                return
            end
            local win = vim.api.nvim_get_current_win()
            local chat = codecompanion.chat({
                params = { adapter = "cursor_cli" },
                approval_mode = acp_approval_mode.cursor_cli or "ask",
                _cursor_lock_silent = true,
            })
            if chat then
                chat.ui:hide()
            end
            if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_set_current_win(win)
            end
        end, 500)

        -- ACP session startup can be slow. Enter during auth races it and kills the session.
        -- Block send until session_id exists, and show status in the chat winbar (not :messages).
        local group = vim.api.nvim_create_augroup("BidhovCodeCompanionStatus", { clear = true })
        local ns_user_model = vim.api.nvim_create_namespace("BidhovCodeCompanionUserModel")

        local function get_chat_model(chat)
            if not chat then
                return nil
            end

            -- 1. Check ACP connection if available
            if chat.acp_connection then
                -- Check get_config_options first (updated by /acp_session_options)
                if chat.acp_connection.get_config_options then
                    local ok, opts_list = pcall(chat.acp_connection.get_config_options, chat.acp_connection)
                    if ok and type(opts_list) == "table" then
                        for _, opt in ipairs(opts_list) do
                            if (opt.id == "model" or opt.category == "model") and opt.currentValue then
                                if opt.options then
                                    for _, o in ipairs(opt.options) do
                                        if o.value == opt.currentValue then
                                            return o.name or o.value
                                        end
                                    end
                                end
                                return opt.currentValue
                            end
                        end
                    end
                end

                -- Check get_models
                if chat.acp_connection.get_models then
                    local ok, m = pcall(chat.acp_connection.get_models, chat.acp_connection)
                    if ok and m and m.currentModelId then
                        if m.availableModels then
                            for _, am in ipairs(m.availableModels) do
                                if am.modelId == m.currentModelId then
                                    return am.name or am.modelId
                                end
                            end
                        end
                        return m.currentModelId
                    end
                end
            end

            -- 2. Check metadata table
            if chat.bufnr and _G.codecompanion_chat_metadata then
                local meta = _G.codecompanion_chat_metadata[chat.bufnr]
                if meta then
                    if meta.config_options and meta.config_options.model and meta.config_options.model.name then
                        return meta.config_options.model.name
                    end
                    if meta.adapter and meta.adapter.model and meta.adapter.model ~= "default" then
                        return meta.adapter.model
                    end
                end
            end

            -- 3. Check adapter settings/schema/model
            local adapter = chat.adapter
            if adapter then
                if adapter.schema and adapter.schema.model and adapter.schema.model.default then
                    return adapter.schema.model.default
                end
                if adapter.model then
                    if type(adapter.model) == "table" and adapter.model.default then
                        return adapter.model.default
                    elseif type(adapter.model) == "string" then
                        return adapter.model
                    end
                end
            end

            return nil
        end

        local function format_model_display(model)
            if not model or model == "" or model == "default" then
                return nil
            end
            if model:lower():match("^auto") then
                return "auto"
            end
            local clean = model:gsub("%[.-%]", ""):gsub("%s+$", "")
            return clean ~= "" and clean or model
        end

        -- ACP session mode from the agent's "mode" config option: Agent | Plan | Ask
        local function get_chat_session_mode(chat)
            if not (chat.acp_connection and chat.acp_connection.get_config_options) then
                return nil
            end
            local ok, opts_list = pcall(chat.acp_connection.get_config_options, chat.acp_connection)
            if not ok or type(opts_list) ~= "table" then
                return nil
            end
            for _, opt in ipairs(opts_list) do
                if (opt.id == "mode" or opt.category == "mode") and opt.currentValue then
                    for _, o in ipairs(opt.options or {}) do
                        if o.value == opt.currentValue then
                            return o.name or o.value
                        end
                    end
                    return opt.currentValue
                end
            end
            return nil
        end

        -- CodeCompanion tool approval for this buffer (changed with gty): Ask | Auto | YOLO
        local approval_labels = { ask = "Ask", auto = "Auto", yolo = "YOLO" }
        local function get_chat_approval(chat)
            if not chat.bufnr then
                return nil
            end
            local ok, approvals = pcall(require, "codecompanion.interactions.chat.tools.approvals")
            if not ok then
                return nil
            end
            local mode = approvals:get_mode(chat.bufnr)
            return approval_labels[mode] or mode
        end

        -- Text shown after the user header: " (model) [session mode | approval]"
        local function get_header_status(chat)
            local model = format_model_display(get_chat_model(chat))
            local text = model and (" (" .. model .. ")") or ""
            local flags = {}
            if chat.adapter and chat.adapter.type == "acp" then
                local mode = get_chat_session_mode(chat)
                if mode then
                    table.insert(flags, mode)
                end
            end
            local approval = get_chat_approval(chat)
            if approval then
                table.insert(flags, approval)
            end
            if #flags > 0 then
                text = text .. " [" .. table.concat(flags, " | ") .. "]"
            end
            return text ~= "" and text or nil
        end

        local function update_user_model_header(bufnr)
            if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
                return
            end
            local ok, codecompanion = pcall(require, "codecompanion")
            if not ok then
                return
            end
            local chat = codecompanion.buf_get_chat(bufnr)
            if not chat then
                return
            end

            local model_text = get_header_status(chat)
            if not model_text then
                vim.api.nvim_buf_clear_namespace(bufnr, ns_user_model, 0, -1)
                return
            end
            local model_len = vim.fn.strwidth(model_text)
            local separator = require("codecompanion.config").display.chat.separator or "-"
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

            vim.api.nvim_buf_clear_namespace(bufnr, ns_user_model, 0, -1)

            local ns_header = vim.api.nvim_create_namespace("CodeCompanion-headers")
            local user_role = (chat.roles and chat.roles.user)
                or (chat.ui and chat.ui.roles and chat.ui.roles.user)
                or "Bidhov"

            for line_idx, content in ipairs(lines) do
                if content:match("^##%s+" .. vim.pesc(user_role)) then
                    local role_end = content:find("%s*" .. vim.pesc(separator) .. "$") or (#content + 1)
                    local insert_col = role_end - 1

                    -- Clear CodeCompanion's default separator extmark on this line so it doesn't overwrite
                    vim.api.nvim_buf_clear_namespace(bufnr, ns_header, line_idx - 1, line_idx)

                    -- Add inline model extmark right beside the user name
                    vim.api.nvim_buf_set_extmark(bufnr, ns_user_model, line_idx - 1, insert_col, {
                        virt_text_pos = "inline",
                        virt_text = { { model_text, "Special" } },
                        priority = 150,
                    })

                    -- Header highlight up to insert_col
                    vim.api.nvim_buf_set_extmark(bufnr, ns_user_model, line_idx - 1, 0, {
                        end_col = insert_col,
                        hl_group = "CodeCompanionChatHeader",
                    })

                    -- Re-add shifted separator
                    local orig_col = vim.fn.strwidth(content) - vim.fn.strwidth(separator)
                    local shifted_win_col = orig_col + model_len
                    vim.api.nvim_buf_set_extmark(bufnr, ns_user_model, line_idx - 1, orig_col, {
                        virt_text_win_col = shifted_win_col,
                        virt_text = { { string.rep(separator, vim.go.columns), "CodeCompanionChatSeparator" } },
                        priority = 100,
                    })
                end
            end
        end

        -- Wrap UI.render_headers so that anytime CodeCompanion re-renders headers,
        -- the user model decoration is automatically applied and kept in sync.
        local ok_ui, UI = pcall(require, "codecompanion.interactions.chat.ui")
        if ok_ui and UI and UI.render_headers then
            local orig_render_headers = UI.render_headers
            UI.render_headers = function(self)
                orig_render_headers(self)
                pcall(update_user_model_header, self.chat_bufnr)
            end
        end

        -- Refresh the header when the agent's session mode/model changes (update_metadata runs after those)...
        local ok_chat, Chat = pcall(require, "codecompanion.interactions.chat")
        if ok_chat and Chat and Chat.update_metadata then
            local orig_update_metadata = Chat.update_metadata
            Chat.update_metadata = function(self, ...)
                local result = orig_update_metadata(self, ...)
                pcall(update_user_model_header, self.bufnr)
                return result
            end
        end

        -- ...and when the approval mode changes (gty, toggle, or set on chat creation).
        local ok_appr, Approvals = pcall(require, "codecompanion.interactions.chat.tools.approvals")
        if ok_appr and Approvals and Approvals.set_mode then
            local orig_set_mode = Approvals.set_mode
            Approvals.set_mode = function(self, bufnr, opts)
                orig_set_mode(self, bufnr, opts)
                pcall(update_user_model_header, bufnr)
            end
        end

        local function set_acp_winbar(bufnr, text, hl)
            if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
                return
            end
            -- vim.b[bufnr].acp_status = text
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(win) == bufnr then
                    vim.wo[win].winbar = "%#" .. (hl or "WarningMsg") .. "#" .. text
                end
            end
        end

        vim.api.nvim_create_autocmd("User", {
            group = group,
            pattern = "CodeCompanionChatCreated",
            callback = function(args)
                local chat = require("codecompanion").buf_get_chat(args.data.bufnr)
                if not chat then
                    return
                end
                -- :q on an unlisted scratch buffer can wipe it and kill the ACP session.
                vim.bo[chat.bufnr].buflisted = true
                vim.bo[chat.bufnr].bufhidden = "hide"
                if chat.adapter.type ~= "acp" then
                    return
                end
                local name = chat.adapter.formatted_name or chat.adapter.name or "ACP agent"
                set_acp_winbar(chat.bufnr, name .. " connecting… wait, Enter is blocked", "WarningMsg")
                chat:add_callback("on_before_submit", function(c)
                    if c.adapter.type ~= "acp" then
                        return
                    end
                    if acp_session_ready(c) then
                        return
                    end
                    local adapter_name = c.adapter.formatted_name or c.adapter.name or "ACP agent"
                    set_acp_winbar(c.bufnr, adapter_name .. " still connecting… Enter is blocked", "WarningMsg")
                    vim.notify("CodeCompanion: " .. adapter_name .. " session not ready, Enter is blocked", vim.log.levels.WARN)
                    return false
                end)
            end,
        })

        vim.api.nvim_create_autocmd("QuitPre", {
            group = group,
            callback = function()
                local bufnr = vim.api.nvim_get_current_buf()
                local chat = require("codecompanion").buf_get_chat(bufnr)
                if not chat then
                    return
                end
                remember_approval(chat)
                vim.bo[bufnr].buflisted = true
                vim.bo[bufnr].bufhidden = "hide"
            end,
        })

        vim.api.nvim_create_autocmd("WinClosed", {
            group = group,
            callback = function(args)
                local win = tonumber(args.match)
                if not win or not vim.api.nvim_win_is_valid(win) then
                    return
                end
                local bufnr = vim.api.nvim_win_get_buf(win)
                local chat = require("codecompanion").buf_get_chat(bufnr)
                if not chat or not chat.adapter or chat.adapter.type ~= "acp" then
                    return
                end
                remember_approval(chat)
                vim.bo[bufnr].buflisted = true
                vim.bo[bufnr].bufhidden = "hide"
                local reopen = chat.adapter.name == "codex" and "<leader>cC" or "<leader>cc"
                local name = chat.adapter.formatted_name or chat.adapter.name
                vim.notify("CodeCompanion: " .. name .. " chat hidden, " .. reopen .. " to reopen", vim.log.levels.INFO)
            end,
        })

        vim.api.nvim_create_autocmd("User", {
            group = group,
            pattern = "CodeCompanionRequestStarted",
            callback = function(args)
                local adapter = args.data and args.data.adapter
                local name = adapter and adapter.name or "unknown"
                vim.notify("CodeCompanion: request sent via " .. name .. ", waiting for response...", vim.log.levels.INFO)
            end,
        })

        vim.api.nvim_create_autocmd("User", {
            group = group,
            pattern = "CodeCompanionRequestFinished",
            callback = function(args)
                local status = args.data and args.data.status or "unknown"
                vim.notify("CodeCompanion: response finished (" .. status .. ")", vim.log.levels.INFO)
            end,
        })

        vim.api.nvim_create_autocmd("User", {
            group = group,
            pattern = "CodeCompanionACPSessionPre",
            callback = function()
                local chat = require("codecompanion").last_chat()
                if chat and chat.adapter.type == "acp" then
                    local name = chat.adapter.formatted_name or chat.adapter.name or "ACP agent"
                    vim.notify("CodeCompanion: " .. name .. " session starting, wait before pressing Enter...", vim.log.levels.INFO)
                    set_acp_winbar(chat.bufnr, name .. " connecting… wait, Enter is blocked", "WarningMsg")
                end
            end,
        })

        vim.api.nvim_create_autocmd("User", {
            group = group,
            pattern = "CodeCompanionACPSessionPost",
            callback = function()
                local chat = require("codecompanion").last_chat()
                if chat and chat.adapter.type == "acp" then
                    local name = chat.adapter.formatted_name or chat.adapter.name or "ACP agent"
                    local model_disp = format_model_display(get_chat_model(chat))
                    local status_model = model_disp and (" (" .. model_disp .. ")") or ""
                    vim.notify("CodeCompanion: " .. name .. status_model .. " session ready", vim.log.levels.INFO)
                    set_acp_winbar(chat.bufnr, name .. status_model .. " ready — press Enter", "DiagnosticOk")
                    pcall(update_user_model_header, chat.bufnr)
                end
            end,
        })

        vim.api.nvim_create_autocmd("User", {
            group = group,
            pattern = "CodeCompanionChatModel",
            callback = function(args)
                local bufnr = args and args.data and args.data.bufnr
                if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
                    local chat = require("codecompanion").buf_get_chat(bufnr)
                    if chat and acp_session_ready(chat) then
                        local name = chat.adapter.formatted_name or chat.adapter.name or "ACP agent"
                        local model_disp = format_model_display(get_chat_model(chat))
                        local status_model = model_disp and (" (" .. model_disp .. ")") or ""
                        set_acp_winbar(chat.bufnr, name .. status_model .. " ready — press Enter", "DiagnosticOk")
                    end
                    pcall(update_user_model_header, bufnr)
                end
            end,
        })
    end,
}
