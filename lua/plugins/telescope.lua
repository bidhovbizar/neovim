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
        { "<leader>ff", function() require('telescope.builtin').find_files() end, desc = "Find files" },
        { "<leader>fg", function() require('telescope').extensions.telescope_config.enhanced_live_grep() end, desc = "Live grep" },
        { "<leader>fm", function() require('telescope').extensions.telescope_config.multi_grep() end, desc = "Multi grep (AND)" },
        { "<leader>fb", function() require('telescope.builtin').buffers() end, desc = "Find buffers" },
        { "<leader>fo", function() require('telescope.builtin').oldfiles() end, desc = "Recent files" },
        { "<leader>ft", function() require('telescope.builtin').git_files() end, desc = "Git files" },
        { "<leader>fr", function() require('telescope.builtin').resume() end, desc = "Resume search" },
        { "<leader>fp", function() require('telescope.builtin').builtin() end, desc = "Find all Telescope builtin picker" },
        { "<leader>fh", function() require('telescope.builtin').help_tags() end, desc = "Help tags" },
    },
    config = function()
        local telescope = require('telescope')

        -- Cache commonly used modules
        local actions = require('telescope.actions')
        local action_state = require('telescope.actions.state')

        -- Initialize case sensitivity state
        vim.g.telescope_case_sensitive = false

        -- Shared vimgrep arguments base
        local rg_base_args = { 'rg', '--color=never', '--no-heading', '--with-filename', '--line-number', '--column' }

        -- Function to create case toggle mapping
        local function create_case_toggle_mapping()
            return function(prompt_bufnr)
                local current_picker = action_state.get_current_picker(prompt_bufnr)
                local prompt = current_picker:_get_prompt()
                local picker_name = current_picker.prompt_title:lower()

                -- Close current picker
                actions.close(prompt_bufnr)

                -- Toggle case sensitivity state
                vim.g.telescope_case_sensitive = not vim.g.telescope_case_sensitive

                -- Show notification
                local mode = vim.g.telescope_case_sensitive and "Case sensitive" or "Smart case"
                vim.notify("Telescope: " .. mode .. " search enabled", vim.log.levels.INFO, { timeout = 1500 })

                -- Helper function to restore prompt and stay in normal mode
                -- Remember 2 defer_fn is needed to ensure proper timing to paste the search string and then exit to normal mode
                local function restore_prompt_and_mode()
                    if prompt and prompt ~= "" then
                        vim.defer_fn(function()
                            vim.api.nvim_feedkeys(prompt, 'n', false)
                            vim.defer_fn(function()
                                vim.cmd('stopinsert')
                            end, 75)
                        end, 100)
                    end
                end

                -- Support case toggle for both live grep and multi grep
                if picker_name:match("live.*grep") then
                    telescope.extensions.telescope_config.enhanced_live_grep()
                    restore_prompt_and_mode()
                elseif picker_name:match("multi.*grep") then
                    telescope.extensions.telescope_config.multi_grep()
                    restore_prompt_and_mode()
                else
                    vim.notify("Case toggle only supported for Live Grep and Multi Grep", vim.log.levels.WARN, { timeout = 1500 })
                end
            end
        end

        -- Minimal setup for faster loading
        telescope.setup({
            defaults = {
                preview = {
                    treesitter = false,
                },
                vimgrep_arguments = {
                    'rg',
                    '--color=never',
                    '--no-heading',
                    '--with-filename',
                    '--line-number',
                    '--column',
                    '--smart-case',
                },
                prompt_prefix = '🔍 ',
                selection_caret = '➤ ',
                layout_strategy = 'bottom_pane',
                mappings = {
                    n = {
                        -- Toggle case sensitivity with <leader>tc in normal mode
                        ["<leader>tc"] = create_case_toggle_mapping(),
                    },
                },
            },
            extensions = {
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = "smart_case",
                }
            }
        })

        -- Load extensions
        telescope.load_extension('fzf')

        -- Create a custom extension for complex functions to defer their loading
        telescope.extensions.telescope_config = {
            enhanced_live_grep = function()
                local builtin = require('telescope.builtin')
                local prompt_title = vim.g.telescope_case_sensitive
                    and "Live Grep (Case Sensitive)"
                    or "Live Grep (Smart Case)"

                builtin.live_grep({
                    prompt_title = prompt_title,
                    vimgrep_arguments = vim.g.telescope_case_sensitive and {
                        'rg', '--color=never', '--no-heading', '--with-filename',
                        '--line-number', '--column', '--case-sensitive'
                    } or {
                        'rg', '--color=never', '--no-heading', '--with-filename',
                        '--line-number', '--column', '--smart-case'
                    }
                })
            end,

            multi_grep = function()
                -- Lazy load multi-grep functionality
                local pickers = require('telescope.pickers')
                local finders = require('telescope.finders')
                local make_entry = require('telescope.make_entry')
                local conf = require('telescope.config').values

                local prompt_title = vim.g.telescope_case_sensitive
                    and "Multi Grep (Case Sensitive) - double space = AND"
                    or "Multi Grep (Smart Case) - double space = AND"

                pickers.new({}, {
                    prompt_title = prompt_title,
                    finder = finders.new_async_job({
                        command_generator = function(prompt)
                            if not prompt or prompt == "" then
                                return nil
                            end

                            local patterns = vim.split(prompt, "  ", { plain = true, trimempty = true })
                            if #patterns == 0 then
                                return nil
                            end

                            -- Use case-sensitive or smart-case based on global state
                            local case_flag = vim.g.telescope_case_sensitive and "--case-sensitive" or "--smart-case"
                            local args = { "rg", "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", case_flag }

                            if #patterns == 1 then
                                table.insert(args, patterns[1])
                                return args
                            end

                            local cmd = table.concat(args, " ") .. " " .. vim.fn.shellescape(patterns[1])
                            for i = 2, #patterns do
                                cmd = cmd .. " | rg --color=never " .. case_flag .. " " .. vim.fn.shellescape(patterns[i])
                            end

                            return { "sh", "-c", cmd }
                        end,
                        entry_maker = make_entry.gen_from_vimgrep({}),
                    }),
                    previewer = conf.grep_previewer({}),
                    sorter = conf.generic_sorter({}),
                }):find()
            end,

            find_plugins = function()
                local builtin = require('telescope.builtin')
                local lazy_path = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy")
                if vim.fn.isdirectory(lazy_path) == 1 then
                    builtin.find_files({
                        cwd = lazy_path,
                        prompt_title = "Plugin Files"
                    })
                else
                    vim.notify("Lazy plugin directory not found: " .. lazy_path, vim.log.levels.ERROR)
                end
            end
        }
    end
}
