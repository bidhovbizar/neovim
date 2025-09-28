return {
    { -- Git plugin for general Git operations
        'tpope/vim-fugitive',
        cmd = { 'Git', 'Git blame', 'Git push', 'Git pull', 'Gdiff' },
        keys = {
            { '<leader>gb', '<cmd>Git blame<cr>', desc = 'Git blame' },
            --{ '<leader>gd3', '<cmd>Gvdiffsplit!<cr>', desc = 'Git 3-way diff' }, -- DiffViews 3 way merge is better than this
        },
    },
    {
        'sindrets/diffview.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',      -- Required dependency
            'nvim-tree/nvim-web-devicons', -- Optional: for file icons
            'tpope/vim-fugitive',         -- Ensure fugitive is loaded with diffview to do Git actions
        },
        keys = {
            { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Open Diffview' },
            { '<leader>gc', '<cmd>DiffviewClose<cr>', desc = 'Close Diffview' },
            { '<leader>gt', '<cmd>DiffviewToggleFiles<cr>', desc = 'Toggle Diffview Files' },
            { '<leader>gfh', '<cmd>DiffviewFileHistory<cr>', desc = 'Git File History' },
        },
        cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles', 'DiffviewFileHistory' },
        config = function()
            require('diffview').setup({
                diff_binaries = false,    -- Show diffs for binaries
                enhanced_diff_hl = true, -- See ':h diffview-config-enhanced_diff_hl'
                git_cmd = { "git" },      -- The git executable followed by default args
                use_icons = true,         -- Requires nvim-web-devicons
                watch_index = true,       -- Auto-refresh when git index changes
                view = {
                    default = {
                        layout = "diff2_horizontal",  -- or "diff2_vertical" based on preference
                    },
                    merge_tool = {
                        layout = "diff3_mixed",  -- 3-way merge with horizontal layout diff3_horizontal
                    },
                },
                file_panel = {
                    listing_style = "tree",
                    win_config = {
                        width = 35,  -- Reasonable default width
                    },
                },
                hooks = {
                    diff_buf_read = function(bufnr)
                        -- Disable git-conflict processing in diffview buffers
                        vim.b[bufnr].git_conflict_disable = true
                    end,
                    view_opened = function()
                        -- Set global flag when diffview is active
                        vim.g.diffview_active = true
                    end,
                    view_closed = function()
                        -- Unset global flag when diffview is closed
                        vim.g.diffview_active = false
                        -- Re-enable git-conflict processing
                        vim.schedule(function()
                            -- Use the command instead of the function since the API might vary
                            vim.cmd('GitConflictRefresh')
                        end)
                    end,
                },
            })
        end,
    },
    { -- Dedicated conflict resolution plugin
        'akinsho/git-conflict.nvim',
        version = "*",
        event = "BufReadPost",
        config = function()
            require('git-conflict').setup({
                default_mappings = true,
                default_commands = true,
                disable_diagnostics = false,
                list_opener = 'copen',
                highlights = {
                    current = "Visual",
                    incoming = "Question",
                }
            })

            -- Add keymap descriptions to existing mappings
            vim.keymap.set('n', 'cq', '<cmd>GitConflictListQf<cr>', { desc = "List All Conflicts in Quickfix" })
            vim.keymap.set('n', 'cr', '<cmd>GitConflictRefresh<cr>', { desc = "Refresh Git Conflicts" })
            vim.keymap.set('n', 'gh', '<cmd>GitConflictHelp<cr>', { desc = "Shows Git Conflict Help" })

            -- Override the process function to check for diffview
            local git_conflict = require('git-conflict')
            local original_process = git_conflict.process

            git_conflict.process = function(bufnr)
                bufnr = bufnr or vim.api.nvim_get_current_buf()
                
                -- Skip processing if in diffview or buffer is marked to disable
                if vim.g.diffview_active or vim.b[bufnr].git_conflict_disable then
                    return
                end
                
                -- Check if buffer belongs to diffview by examining buffer name or filetype
                local buf_name = vim.api.nvim_buf_get_name(bufnr)
                local buf_filetype = vim.bo[bufnr].filetype
                
                -- Skip diffview buffers (including file panel previews)
                if buf_name:match("diffview://") or 
                   buf_filetype == "DiffviewFiles" or
                   buf_filetype == "DiffviewFileHistory" then
                    return
                end
                
                -- Check if we're in a diffview window (additional safety check)
                local win = vim.fn.bufwinid(bufnr)
                if win ~= -1 then
                    local win_config = vim.api.nvim_win_get_config(win)
                    if win_config and win_config.relative and win_config.relative ~= "" then
                        -- This might be a floating diffview window, skip it
                        return
                    end
                end
                
                -- Wrap the original process in a pcall to catch any errors
                local ok, result = pcall(original_process, bufnr)
                if not ok then
                    -- If there's an error, it might be due to diffview interference
                    -- Check if we're actually in a diffview context and skip silently
                    local current_tab = vim.api.nvim_get_current_tabpage()
                    local tab_wins = vim.api.nvim_tabpage_list_wins(current_tab)
                    
                    for _, w in ipairs(tab_wins) do
                        local buf = vim.api.nvim_win_get_buf(w)
                        local name = vim.api.nvim_buf_get_name(buf)
                        local ft = vim.bo[buf].filetype
                        if name:match("diffview://") or ft:match("Diffview") then
                            -- We're in a diffview context, silently return
                            return
                        end
                    end
                    
                    -- If we're not in diffview, re-raise the error
                    error(result)
                end
                
                return result
            end

            -- Create hint display for git conflicts (only when not in diffview)
            local hint_ns = vim.api.nvim_create_namespace("git_conflict_hints")
            local hint_group = vim.api.nvim_create_augroup("GitConflictHints", { clear = true })

            local function show_conflict_hints()
                -- Don't show hints in diffview
                if vim.g.diffview_active then
                    return
                end

                local bufnr = vim.api.nvim_get_current_buf()
                
                -- Skip if buffer is marked to disable git-conflict
                if vim.b[bufnr].git_conflict_disable then
                    return
                end

                local cursor_line = vim.api.nvim_win_get_cursor(0)[1]

                -- Get all lines in the buffer
                local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

                -- Clear existing hints
                vim.api.nvim_buf_clear_namespace(bufnr, hint_ns, 0, -1)

                -- Find conflict boundaries and check if cursor is within any conflict hunk
                local conflict_start = nil
                local conflict_end = nil
                local header_line = nil

                for i, line in ipairs(lines) do
                    if line:match("^<<<<<<<") then
                        conflict_start = i
                        header_line = i - 1  -- Convert to 0-based indexing
                    elseif line:match("^>>>>>>>") and conflict_start then
                        conflict_end = i

                        -- Check if cursor is within this conflict hunk
                        if cursor_line >= conflict_start and cursor_line <= conflict_end then
                            -- Show hint as virtual text on the conflict header line
                            local hint_text = "[co: OURS, ct: THEIRS, [x: PREV, ]x: NEXT, cr: REFRESH]"
                            vim.api.nvim_buf_set_extmark(bufnr, hint_ns, header_line, 0, {
                                virt_text = {{ hint_text, "DiagnosticVirtualLinesError" }},
                                virt_text_pos = "right_align",
                                priority = 1000,
                            })
                            break
                        end

                        -- Reset for next potential conflict
                        conflict_start = nil
                        conflict_end = nil
                        header_line = nil
                    end
                end
            end

            -- Set up autocommands to show hints (but skip in diffview)
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufEnter" }, {
                group = hint_group,
                callback = function()
                    if not vim.g.diffview_active then
                        show_conflict_hints()
                    end
                end,
            })

            -- Optional: Create a command to show help
            vim.api.nvim_create_user_command("GitConflictHelp", function()
                local help_text = {
                    "Git Conflict Resolution:",
                    "",
                    "CONFLICT RESOLUTION:",
                    "co - Choose Ours (HEAD/current branch)",
                    "ct - Choose Theirs (incoming/merge branch)",
                    "cb - Choose Both (keep both changes)",
                    "c0 - Choose None (delete conflict)",
                    "cr - Refresh Git Conflicts",
                    "cq - List All Conflicts in Quickfix",
                    "gh - Show Git Conflict Help",
                    "",
                    "NAVIGATION:",
                    "]x - Go to Next Conflict",
                    "[x - Go to Previous Conflict",
                    "",
                    "COMMANDS:",
                    ":GitConflictListQf - List all conflicts in quickfix",
                    ":GitConflictRefresh - Refresh conflict detection",
                }

                local buf = vim.api.nvim_create_buf(false, true)
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, help_text)
                vim.bo[buf].modifiable = false
                vim.bo[buf].filetype = 'help'

                local width = 50
                local height = #help_text + 2
                local opts = {
                    relative = 'editor',
                    width = width,
                    height = height,
                    col = (vim.o.columns - width) / 2,
                    row = (vim.o.lines - height) / 2,
                    style = 'minimal',
                    border = 'rounded',
                    title = ' Git Conflict Help ',
                    title_pos = 'center'
                }

                local win = vim.api.nvim_open_win(buf, true, opts)
                vim.wo[win].winhl = 'Normal:Normal,FloatBorder:FloatBorder'

                -- Close on any key press
                vim.keymap.set('n', '<ESC>', '<cmd>close<cr>', { buffer = buf })
                vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf })
            end, { desc = "Show git conflict resolution help" })
        end
    },
}
