return {
    { -- Git plugin for general Git operations
        'tpope/vim-fugitive',
        cmd = { 'Git', 'Git blame', 'Git push', 'Git pull', 'Gdiff' },
        keys = {
            { '<leader>gb', '<cmd>Git blame<cr>', desc = 'Git blame' },
            { '<leader>gd', '<cmd>Gvdiffsplit!<cr>', desc = 'Git 3-way diff' },
            { '<leader>gs', '<cmd>Git status<cr>', desc = 'Git status' },
            { '<leader>gc', '<cmd>Git commit<cr>', desc = 'Git commit' },
        },
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
            vim.keymap.set('n', 'co', '<Plug>(git-conflict-ours)', { desc = "Choose Ours (HEAD)" })
            vim.keymap.set('n', 'ct', '<Plug>(git-conflict-theirs)', { desc = "Choose Theirs (Incoming)" })
            vim.keymap.set('n', 'cb', '<Plug>(git-conflict-both)', { desc = "Choose Both" })
            vim.keymap.set('n', 'c0', '<Plug>(git-conflict-none)', { desc = "Choose None" })
            vim.keymap.set('n', ']x', '<Plug>(git-conflict-next-conflict)', { desc = "Next Conflict" })
            vim.keymap.set('n', '[x', '<Plug>(git-conflict-prev-conflict)', { desc = "Previous Conflict" })
            vim.keymap.set('n', 'cr', '<cmd>GitConflictRefresh<cr>', { desc = "Refresh Git Conflicts" })
            vim.keymap.set('n', 'ch', '<cmd>GitConflictHelp<cr>', { desc = "Shows Git Conflict Help" })

            -- Create hint display for git conflicts
            local hint_ns = vim.api.nvim_create_namespace("git_conflict_hints")
            local hint_group = vim.api.nvim_create_augroup("GitConflictHints", { clear = true })

            local function show_conflict_hints()
                local bufnr = vim.api.nvim_get_current_buf()
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
                                virt_text = {{ hint_text, "ErrorMsg" }},
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

            -- Set up autocommands to show hints
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufEnter" }, {
                group = hint_group,
                callback = show_conflict_hints,
            })

            -- Optional: Create a command to show help
            vim.api.nvim_create_user_command("GitConflictHelp", function()
                local help_text = {
                    "Git Conflict Resolution:",
                    "",
                    "co - Choose Ours (HEAD/current branch)",
                    "ct - Choose Theirs (incoming/merge branch)",
                    "cb - Choose Both (keep both changes)",
                    "c0 - Choose None (delete conflict)",
                    "",
                    "]x - Go to Next Conflict",
                    "[x - Go to Previous Conflict",
                    "",
                    ":GitConflictListQf - List all conflicts"
                }

                local buf = vim.api.nvim_create_buf(false, true)
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, help_text)
                vim.bo[buf].modifiable = false
                vim.bo[buf].filetype = 'help'
                --vim.api.nvim_buf_set_option(buf, 'modifiable', false)
                --vim.api.nvim_buf_set_option(buf, 'filetype', 'help')

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
                --vim.api.nvim_win_set_option(win, 'winhl', 'Normal:Normal,FloatBorder:FloatBorder')
                vim.wo[win].winhl = 'Normal:Normal,FloatBorder:FloatBorder'

                -- Close on any key press
                vim.keymap.set('n', '<ESC>', '<cmd>close<cr>', { buffer = buf })
                vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf })
            end, { desc = "Show git conflict resolution help" })
        end
    },
}
