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
        { "<leader>fr", desc = "Telescope resume last search" },
        { "<leader>fh", desc = "Telescope search history" },
    },
    config = function()
        local telescope = require('telescope')
        local builtin = require('telescope.builtin')

        -- Search history storage
        local search_history = {
            live_grep = {},
            find_files = {},
            max_history = 10
        }

        -- Function to add search to history
        local function add_to_history(search_type, query)
            if query and query ~= "" then
                local history = search_history[search_type]
                -- Remove if already exists to avoid duplicates
                for i, item in ipairs(history) do
                    if item == query then
                        table.remove(history, i)
                        break
                    end
                end
                -- Add to beginning
                table.insert(history, 1, query)
                -- Keep only max_history items
                if #history > search_history.max_history then
                    table.remove(history)
                end
            end
        end

        -- Enhanced builtin functions with history tracking
        local function enhanced_live_grep(opts)
            opts = opts or {}
            local original_attach_mappings = opts.attach_mappings

            opts.attach_mappings = function(prompt_bufnr, map)
                local actions = require('telescope.actions')
                local action_state = require('telescope.actions.state')

                -- Override the default select action to save search to history
                local function enhanced_select_default()
                    local current_picker = action_state.get_current_picker(prompt_bufnr)
                    local query = current_picker:_get_prompt()
                    add_to_history('live_grep', query)
                    actions.select_default(prompt_bufnr)
                end

                map('i', '<CR>', enhanced_select_default)
                map('n', '<CR>', enhanced_select_default)

                -- Call original attach_mappings if provided
                if original_attach_mappings then
                    return original_attach_mappings(prompt_bufnr, map)
                end
                return true
            end

            builtin.live_grep(opts)
        end

        local function enhanced_find_files(opts)
            opts = opts or {}
            local original_attach_mappings = opts.attach_mappings

            opts.attach_mappings = function(prompt_bufnr, map)
                local actions = require('telescope.actions')
                local action_state = require('telescope.actions.state')

                local function enhanced_select_default()
                    local current_picker = action_state.get_current_picker(prompt_bufnr)
                    local query = current_picker:_get_prompt()
                    add_to_history('find_files', query)
                    actions.select_default(prompt_bufnr)
                end

                map('i', '<CR>', enhanced_select_default)
                map('n', '<CR>', enhanced_select_default)

                if original_attach_mappings then
                    return original_attach_mappings(prompt_bufnr, map)
                end
                return true
            end

            builtin.find_files(opts)
        end

        -- Function to show search history picker
        local function show_search_history(search_type)
            local pickers = require('telescope.pickers')
            local finders = require('telescope.finders')
            local conf = require('telescope.config').values
            local actions = require('telescope.actions')
            local action_state = require('telescope.actions.state')

            local history = search_history[search_type] or {}
            if #history == 0 then
                vim.notify("No search history for " .. search_type, vim.log.levels.INFO)
                return
            end

            pickers.new({}, {
                prompt_title = string.format("%s Search History", search_type:gsub("_", " "):gsub("^%l", string.upper)),
                finder = finders.new_table {
                    results = history,
                    entry_maker = function(entry)
                        return {
                            value = entry,
                            display = entry,
                            ordinal = entry,
                        }
                    end,
                },
                sorter = conf.generic_sorter({}),
                attach_mappings = function(prompt_bufnr, map)
                    actions.select_default:replace(function()
                        local selection = action_state.get_selected_entry()
                        actions.close(prompt_bufnr)
                        if selection then
                            if search_type == 'live_grep' then
                                enhanced_live_grep({ default_text = selection.value })
                            elseif search_type == 'find_files' then
                                enhanced_find_files({ default_text = selection.value })
                            end
                        end
                    end)
                    return true
                end,
            }):find()
        end

        -- Quick access to last searches
        local function repeat_last_search(search_type)
            local history = search_history[search_type]
            if history and #history > 0 then
                local last_query = history[1]
                if search_type == 'live_grep' then
                    enhanced_live_grep({ default_text = last_query })
                elseif search_type == 'find_files' then
                    enhanced_find_files({ default_text = last_query })
                end
            else
                vim.notify("No previous " .. search_type:gsub("_", " ") .. " search found", vim.log.levels.WARN)
            end
        end

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
        -- Main telescope functions with enhanced history tracking
        vim.keymap.set('n', '<leader>ff', function() enhanced_find_files() end, { desc = 'Telescope find files' })
        vim.keymap.set('n', '<leader>fg', function() enhanced_live_grep() end, { desc = 'Telescope live grep' })
        vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
        -- To clear any file in the buffer do :ls to find files or <leader>fb then to remove do :bd <buffer_number> e.g. :bd 33
        -- To clear all buffers do :bwipeout
        vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = 'Telescope oldfiles' })
        vim.keymap.set('n', '<leader>ft', builtin.git_files, { desc = 'Telescope git files' })
        vim.keymap.set('n', '<leader>fH', builtin.help_tags, { desc = 'Telescope help tags' })

        -- Resume functionality - reopens the last telescope picker with same state
        vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = 'Telescope resume last search' })

        -- Search history functionality
        vim.keymap.set('n', '<leader>fh', function()
            vim.ui.select({'live_grep', 'find_files'}, {
                prompt = 'Select search type:',
                format_item = function(item)
                    return item:gsub('_', ' '):gsub('^%l', string.upper) .. ' History'
                end,
            }, function(choice)
                if choice then
                    show_search_history(choice)
                end
            end)
        end, { desc = 'Show search history' })

        -- Quick access to last searches
        vim.keymap.set('n', '<leader>fgg', function() repeat_last_search('live_grep') end, { desc = 'Repeat last live grep' })
        vim.keymap.set('n', '<leader>fff', function() repeat_last_search('find_files') end, { desc = 'Repeat last find files' })

        -- Show specific search history
        vim.keymap.set('n', '<leader>fhg', function() show_search_history('live_grep') end, { desc = 'Live grep history' })
        vim.keymap.set('n', '<leader>fhf', function() show_search_history('find_files') end, { desc = 'Find files history' })
    end
}
