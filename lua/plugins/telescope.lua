return {
    'nvim-telescope/telescope.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            build = 'make'
        }
    },
    cmd = "Telescope",
    keys = {
        { "<leader>ff", desc = "Telescope find files" },
        { "<leader>fg", desc = "Telescope live grep" },
        { "<leader>fb", desc = "Telescope buffers" },
        { "<leader>fo", desc = "Telescope oldfiles" },
        { "<leader>ft", desc = "Telescope git files" },
        { "<leader>fr", desc = "Telescope resume last search" },
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

        -- Initialize case sensitivity state
        vim.g.telescope_case_sensitive = false

        -- Function to create case toggle mapping
        local function create_case_toggle_mapping()
            return function(prompt_bufnr)
                local actions = require('telescope.actions')
                local action_state = require('telescope.actions.state')
                local current_picker = action_state.get_current_picker(prompt_bufnr)
                local prompt = current_picker:_get_prompt()
                local picker_name = current_picker.prompt_title

                -- Close current picker
                actions.close(prompt_bufnr)

                -- Toggle case sensitivity state
                vim.g.telescope_case_sensitive = not vim.g.telescope_case_sensitive

                -- Show notification
                if vim.g.telescope_case_sensitive then
                    vim.notify("Telescope: Case sensitive search enabled", vim.log.levels.INFO, { timeout = 1500 })
                else
                    vim.notify("Telescope: Smart case search enabled", vim.log.levels.INFO, { timeout = 1500 })
                end

                -- Determine which picker to reopen based on the current one
                if picker_name:lower():match("grep") then
                    -- Reopen with live_grep using enhanced function for history tracking
                    enhanced_live_grep({
                        default_text = prompt,
                        vimgrep_arguments = vim.g.telescope_case_sensitive and {
                            'rg', '--color=never', '--no-heading', '--with-filename',
                            '--line-number', '--column', '--case-sensitive'
                        } or {
                            'rg', '--color=never', '--no-heading', '--with-filename',
                            '--line-number', '--column', '--smart-case'
                        }
                    })
                elseif picker_name:lower():match("find") or picker_name:lower():match("files") then
                    -- Reopen with find_files using enhanced function for history tracking
                    -- Update fzf extension configuration dynamically
                    telescope.setup({
                        extensions = {
                            fzf = {
                                fuzzy = true,
                                override_generic_sorter = true,
                                override_file_sorter = true,
                                case_mode = vim.g.telescope_case_sensitive and "respect_case" or "smart_case"
                            }
                        }
                    })
                    telescope.load_extension('fzf')

                    enhanced_find_files({
                        default_text = prompt
                    })
                else
                    -- For other pickers, default to their builtin version
                    vim.notify("Case toggle not supported for this picker", vim.log.levels.WARN, { timeout = 1500 })
                end
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
                -- Leaving everything empty is the best as it will take the default settings from telescope-fzf-native

                -- Use fzf-native as the default sorter for better performance and case sensitivity
                --file_sorter = require('telescope.sorters').get_fzf_sorter,
                --generic_sorter = require('telescope.sorters').get_fzf_sorter,

                -- Alternative sorters (replace fzf lines with one of these):
                -- file_sorter = require('telescope.sorters').get_generic_fuzzy_sorter,
                -- generic_sorter = require('telescope.sorters').get_generic_fuzzy_sorter,

                -- Or use substr matcher (faster but less fuzzy):
                -- file_sorter = require('telescope.sorters').get_substr_matcher,
                -- generic_sorter = require('telescope.sorters').get_substr_matcher,

                -- Or use regex matcher:
                -- file_sorter = require('telescope.sorters').get_regex_matcher,
                -- generic_sorter = require('telescope.sorters').get_regex_matcher,

                -- Or use get_fzy_sorter() - FZY algorithm implementation
                -- file_sorter = require('telescope.sorters').get_fzy_sorter,
                -- generic_sorter = require('telescope.sorters').get_fzy_sorter,

                -- Use fzf-native as the default sorter for better performance and case sensitivity
                --file_sorter = require('telescope').extensions.fzf.native_fzf_sorter(),
                --generic_sorter = require('telescope').extensions.fzf.native_fzf_sorter() ,

                mappings = {
                    i = {
                        -- Toggle case sensitivity with <leader>tc in insert mode
                        ["<leader>tc"] = create_case_toggle_mapping(),
                    },
                    n = {
                        -- Toggle case sensitivity with <leader>tc in normal mode
                        ["<leader>tc"] = create_case_toggle_mapping(),
                    },
                },
            },
            extensions = {
                fzf = {
                    fuzzy = true,                    -- false will only do exact matching
                    override_generic_sorter = true,  -- override the generic sorter
                    override_file_sorter = true,     -- override the file sorter
                    case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                }
            }
        })

        -- Load fzf extension
        telescope.load_extension('fzf')
        -- Main telescope functions with enhanced history tracking
        vim.keymap.set('n', '<leader>ff', function() enhanced_find_files() end, { desc = 'Telescope find files' })
        vim.keymap.set('n', '<leader>fg', function() enhanced_live_grep() end, { desc = 'Telescope live grep' })
        vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
        -- To clear any file in the buffer do :ls to find files or <leader>fb then to remove do :bd <buffer_number> e.g. :bd 33
        -- To clear all buffers do :bwipeout
        vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = 'Telescope oldfiles' })
        vim.keymap.set('n', '<leader>ft', builtin.git_files, { desc = 'Telescope git files' })

        -- Resume functionality - reopens the last telescope picker with same state
        vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = 'Telescope resume last search' })

        -- Quick access to last searches
        vim.keymap.set('n', '<leader>ffr', function() repeat_last_search('find_files') end, { desc = 'Repeat last find files' })
        vim.keymap.set('n', '<leader>fgr', function() repeat_last_search('live_grep') end, { desc = 'Repeat last live grep' })

        -- Show specific search history
        vim.keymap.set('n', '<leader>ffh', function() show_search_history('find_files') end, { desc = 'Find files history' })
        vim.keymap.set('n', '<leader>fgh', function() show_search_history('live_grep') end, { desc = 'Live grep history' })
    end
}
