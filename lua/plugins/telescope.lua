return {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = "Telescope",
    keys = {
        { "<leader>ff", desc = "Telescope find files" },
        { "<leader>fg", desc = "Telescope live grep" },
        { "<leader>fb", desc = "Telescope buffers" },
        { "<leader>fo", desc = "Telescope oldfiles" },
        { "<leader>ft", desc = "Telescope git files" },
        { "<leader>fH", desc = "Telescope help tags" },
    },
    config = function()
        local telescope = require('telescope')
        local builtin = require('telescope.builtin')
        telescope.setup({
            defaults = {
                preview = {
                    treesitter = false, -- Disable treesitter in previews so opening files from telescope starts with syntax highlighting
                },
                -- Smart case: lowercase = case-insensitive, mixed case = case-sensitive
                vimgrep_arguments = {
                    'rg',
                    '--color=never',
                    '--no-heading',
                    '--with-filename',
                    '--line-number',
                    '--column',
                    '--smart-case', -- Smart case behavior
                },
                mappings = {
                    i = {
                        -- Toggle case sensitivity with <leader>ftc in insert mode
                        ["<leader>ftc"] = function(prompt_bufnr)
                            -- Simple approach - just print for debugging first
                            print("Telescope: Toggle pressed in insert mode")
                            -- Try to restart the search with opposite case setting
                            local current_picker = require('telescope.actions.state').get_current_picker(prompt_bufnr)
                            local prompt = current_picker:_get_prompt()
                            -- Close current picker and restart with opposite case sensitivity
                            require('telescope.actions').close(prompt_bufnr)
                            -- Create a simple toggle state
                            if not vim.g.telescope_case_sensitive then
                                vim.g.telescope_case_sensitive = true
                                -- Restart search with case sensitive
                                require('telescope.builtin').live_grep({
                                    default_text = prompt,
                                    vimgrep_arguments = {
                                        'rg', '--color=never', '--no-heading', '--with-filename',
                                        '--line-number', '--column', '--case-sensitive'
                                    },
                                    attach_mappings = function(_)
                                        -- Stay in normal mode and show message after telescope opens
                                        vim.schedule(function()
                                            vim.cmd('stopinsert') -- Exit insert mode
                                            vim.notify("Telescope: Case sensitive search enabled", vim.log.levels.INFO, { timeout = 3000 })
                                        end)
                                        return true
                                    end
                                })
                            else
                                vim.g.telescope_case_sensitive = false
                                require('telescope.builtin').live_grep({
                                    default_text = prompt,
                                    vimgrep_arguments = {
                                        'rg', '--color=never', '--no-heading', '--with-filename',
                                        '--line-number', '--column', '--smart-case'
                                    },
                                    attach_mappings = function(_)
                                        -- Stay in normal mode and show message after telescope opens
                                        vim.schedule(function()
                                            vim.cmd('stopinsert') -- Exit insert mode
                                            vim.notify("Telescope: Smart case search enabled", vim.log.levels.INFO, { timeout = 3000 })
                                        end)
                                        return true
                                    end
                                })
                            end
                        end,
                    },
                    n = {
                        -- Toggle case sensitivity with <leader>ftc in normal mode
                        ["<leader>ftc"] = function(prompt_bufnr)
                            print("Telescope: Toggle pressed in normal mode")
                            local current_picker = require('telescope.actions.state').get_current_picker(prompt_bufnr)
                            local prompt = current_picker:_get_prompt()
                            require('telescope.actions').close(prompt_bufnr)
                            if not vim.g.telescope_case_sensitive then
                                vim.g.telescope_case_sensitive = true
                                vim.notify("Telescope: Case sensitive search enabled", vim.log.levels.INFO, { timeout = 2000 })
                                require('telescope.builtin').live_grep({
                                    default_text = prompt,
                                    vimgrep_arguments = {
                                        'rg', '--color=never', '--no-heading', '--with-filename',
                                        '--line-number', '--column', '--case-sensitive'
                                    }
                                })
                            else
                                vim.g.telescope_case_sensitive = false
                                vim.notify("Telescope: Smart case search enabled", vim.log.levels.INFO, { timeout = 2000 })
                                require('telescope.builtin').live_grep({
                                    default_text = prompt,
                                    vimgrep_arguments = {
                                        'rg', '--color=never', '--no-heading', '--with-filename',
                                        '--line-number', '--column', '--smart-case'
                                    }
                                })
                            end
                        end,
                    },
                },
            },
        })
        vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
        --vim.keymap.set('n', '<leader>ftc', builtin.live_grep, { desc = 'toggle case sensitivity when inside telescope' })
        vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
        -- To clear any file in the buffer do :ls to find files or <leader>fb then to remove do :bd <buffer_number> e.g. :bd 33
        -- To clear all buffers do :bwipeout
        vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = 'Telescope oldfiles' })
        vim.keymap.set('n', '<leader>ft', builtin.git_files, { desc = 'Telescope oldfiles' })
        vim.keymap.set('n', '<leader>fH', builtin.help_tags, { desc = 'Telescope help tags' })
    end
}
