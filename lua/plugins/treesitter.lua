return {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    branch = "main",
    build = ":TSUpdate",
    event = "VeryLazy",
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
        "nvim-treesitter/nvim-treesitter-context",
    },
    config = function()
        local ignored_parsers = { "javascript" }

        -- Main branch: install parsers
        -- Enable highlighting (main branch uses vim.treesitter)
        require("nvim-treesitter.configs").setup({
            ensure_installed = { "bash", "python", "go", "json", "lua", "vim", "yaml" },
            sync_install = false,
            auto_install = true,
            ignore_install = ignored_parsers,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            indent = { enable = true },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<leader>vv",
                    node_incremental = "+",
                    scope_incremental = false,
                    node_decremental = "_",
                },
            },
            -- textobjects config goes HERE, inside the main setup()
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        ["af"] = { query = "@function.outer", desc = "around a function" },
                        ["if"] = { query = "@function.inner", desc = "inner part of a function" },
                        ["ac"] = { query = "@class.outer", desc = "around a class" },
                        ["ic"] = { query = "@class.inner", desc = "inner part of a class" },
                        ["ai"] = { query = "@conditional.outer", desc = "around an if statement" },
                        ["ii"] = { query = "@conditional.inner", desc = "inner part of an if statement" },
                        ["al"] = { query = "@loop.outer", desc = "around a loop" },
                        ["il"] = { query = "@loop.inner", desc = "inner part of a loop" },
                        ["av"] = { query = "@parameter.outer", desc = "around a parameter or variable" },
                        ["iv"] = { query = "@parameter.inner", desc = "inside a parameter or variable" },
                    },
                    selection_modes = {
                        ["@parameter.outer"] = "v",
                        ["@parameter.inner"] = "v",
                        ["@function.outer"] = "v",
                        ["@conditional.outer"] = "V",
                        ["@loop.outer"] = "V",
                        ["@class.outer"] = "<c-v>",
                    },
                    include_surrounding_whitespace = false,
                },
                move = {
                    enable = true,
                    set_jumps = true,
                    goto_previous_start = {
                        ["[f"] = { query = "@function.outer", desc = "Previous function" },
                        ["[C"] = { query = "@class.outer", desc = "Previous class" },
                        ["[v"] = { query = "@parameter.inner", desc = "Previous parameter" },
                        ["[t"] = { query = "@statement.outer", desc = "Previous statement" },
                        ["[b"] = { query = "@block.outer", desc = "Previous block" },
                    },
                    goto_next_start = {
                        ["]f"] = { query = "@function.outer", desc = "Next function" },
                        ["]C"] = { query = "@class.outer", desc = "Next class" },
                        ["]v"] = { query = "@parameter.inner", desc = "Next parameter" },
                        ["]t"] = { query = "@statement.outer", desc = "Next statement" },
                        ["]b"] = { query = "@block.outer", desc = "Next block" },
                    },
                },
                swap = {
                    enable = true,
                    swap_next = {
                        ["<leader>n"] = "@parameter.inner",
                    },
                    swap_previous = {
                        ["<leader>p"] = "@parameter.inner",
                    },
                },
            },
        })

        vim.api.nvim_create_autocmd("FileType", {
            callback = function(args)
                local ft = vim.bo[args.buf].filetype
                if not vim.tbl_contains(ignored_parsers, ft) then
                    pcall(vim.treesitter.start, args.buf)
                end
            end,
        })

        -- Textobjects (still uses nvim-treesitter-textobjects plugin)
        -- Configure treesitter-context for sticky function headers
        require('treesitter-context').setup({
            enable = true,
            max_lines = 3,
            min_window_height = 0,
            line_numbers = true,
            multiline_threshold = 20,
            trim_scope = 'inner',
            mode = 'cursor',
            separator = nil,
            zindex = 20,
            on_attach = nil,
            patterns = {
                python = {
                    'function_definition',
                    'class_definition',
                    'for_statement',
                    'if_statement',
                    'while_statement',
                    'with_statement',
                    'try_statement',
                },
                go = {
                    'function_declaration',
                    'method_declaration',
                    'if_statement',
                    'for_statement',
                    'switch_statement',
                    'select_statement',
                    'type_declaration',
                    'struct_type',
                    'interface_type',
                },
                lua = {
                    'function_declaration',
                    'function_definition',
                    'if_statement',
                    'for_statement',
                    'while_statement',
                },
            },
        })
    end,
}

--return {
--    "nvim-treesitter/nvim-treesitter",
--    version = false,
--    build = ":TSUpdate",
--    event = "VeryLazy",
--    --event = { "BufReadPost", "BufNewFile" },
--    --event = "InsertEnter",
--    --lazy = true, -- This means don't load automatically, only load when called
--    dependencies = {
--        "nvim-treesitter/nvim-treesitter-textobjects",
--        "nvim-treesitter/nvim-treesitter-context",
--    },
--    config = function()
--        -- Main branch: install parsers
--        require("nvim-treesitter").setup({
--            sync_install = false,
--            ignore_install = { "javascript" },
--            modules = {},
--            highlight = {
--                enable = true,
--                additional_vim_regex_highlighting = false,
--            },
--            indent = { enable = true },
--            auto_install = true,
--            ensure_installed = {
--                "bash",
--                "python",
--                "go",
--                "json",
--                "lua",
--                "vim",
--                "yaml",
--            },
--            incremental_selection = {
--                enable = true,
--                keymaps = {
--                    -- Place your cursor on a code block and <leader>vv to select it the logical block
--                    init_selection = "<leader>vv",
--                    -- After the selection press "+" to select the next higher level block from the cursor
--                    node_incremental = "+",
--                    scope_incremental = false,
--                    -- After the selection press "_" to select the next lower level block from the cursor
--                    node_decremental = "_",
--                },
--            },
--            textobjects = {
--                select = {
--                    enable = true,
--                    lookahead = true,
--
--                    keymaps = {
--                        -- You can use the capture groups defined in textobjects.scm
--                        -- This section for change around/in function
--                        ["af"] = { query = "@function.outer", desc = "around a function" },
--                        ["if"] = { query = "@function.inner", desc = "inner part of a function" },
--                        -- This section for change around/in class
--                        ["ac"] = { query = "@class.outer", desc = "around a class" },
--                        ["ic"] = { query = "@class.inner", desc = "inner part of a class" },
--                        -- This section for change around/in if or else
--                        ["ai"] = { query = "@conditional.outer", desc = "around an if statement" },
--                        ["ii"] = { query = "@conditional.inner", desc = "inner part of an if statement" },
--                        -- This section for change around/in loop
--                        ["al"] = { query = "@loop.outer", desc = "around a loop" },
--                        ["il"] = { query = "@loop.inner", desc = "inner part of a loop" },
--                        -- This section for change around/in parameter
--                        ["av"] = { query = "@parameter.outer", desc = "around a parameter or variable" },
--                        ["iv"] = { query = "@parameter.inner", desc = "inside a parameter or variable" },
--                        -- This section for change around/in paragraph
--                        -- Don't need this block as its already defined in vim and treesitter is not needed
--                        --["ap"] = { query = "@paragraph.outer", desc = "around a paragraph" },
--                        --["ip"] = { query = "@paragraph.inner", desc = "inside a paragraph" },
--                    },
--                    selection_modes = {
--                        ["@parameter.outer"] = "v",   -- charwise
--                        ["@parameter.inner"] = "v",   -- charwise
--                        ["@function.outer"] = "v",    -- charwise
--                        ["@conditional.outer"] = "V", -- linewise
--                        ["@loop.outer"] = "V",        -- linewise
--                        ["@class.outer"] = "<c-v>",   -- blockwise
--                    },
--                    include_surrounding_whitespace = false,
--                },
--                move = {
--                    enable = true,
--                    set_jumps = true, -- whether to set jumps in the jumplist
--                    goto_previous_start = {
--                        ["[f"] = { query = "@function.outer", desc = "Previous function" },
--                        ["[C"] = { query = "@class.outer", desc = "Previous class" }, -- [c is used for hunk
--                        ["[v"] = { query = "@parameter.inner", desc = "Previous parameter" },
--                        ["[t"] = { query = "@statement.outer", desc = "Previous statement" },
--                        ["[b"] = { query = "@block.outer", desc = "Previous block" },
--                    },
--                    goto_next_start = {
--                        ["]f"] = { query = "@function.outer", desc = "Next function" },
--                        ["]C"] = { query = "@class.outer", desc = "Next class" }, --]c is used for hunk
--                        ["]v"] = { query = "@parameter.inner", desc = "Next parameter" },
--                        ["]t"] = { query = "@statement.outer", desc = "Next statement" },
--                        ["]b"] = { query = "@block.outer", desc = "Next block" },
--                    },
--                },
--                swap = {
--                    enable = true,
--                    --- To move a parameter to the next position from where your cursor is placed
--                    swap_next = {
--                        ["<leader>n"] = "@parameter.inner",
--                    },
--                    --- To move a parameter to the previous position from where your cursor is placed
--                    swap_previous = {
--                        ["<leader>p"] = "@parameter.inner",
--                    },
--                },
--            },
--        })
--
--        -- Configure treesitter-context for sticky function headers
--        require('treesitter-context').setup({
--            enable = true,
--            max_lines = 3,            -- How many lines the window should span.
--            min_window_height = 0,    -- Minimum editor window height to enable context
--            line_numbers = true,      -- Show line numbers in context
--            multiline_threshold = 20, -- Maximum number of lines to show for a single context
--            trim_scope = 'inner',     -- Which context lines to discard if `max_lines` is exceeded
--            --trim_scope = 'outer',   -- Which context lines to discard if `max_lines` is exceeded
--            mode = 'cursor',          -- Line used to calculate context. 'cursor' or 'topline'
--            separator = nil,          -- Separator between context and content (nil uses default)
--            zindex = 20,              -- Z-index of the context window
--            on_attach = nil,          -- Callback when attaching to a buffer
--
--            -- You can customize patterns per language
--            patterns = {
--                -- For Python, show function definitions, class definitions, etc.
--                python = {
--                    'function_definition',
--                    'class_definition',
--                    'for_statement',
--                    'if_statement',
--                    'while_statement',
--                    'with_statement',
--                    'try_statement',
--                },
--                -- For Go, show function declarations, method declarations, etc.
--                go = {
--                    'function_declaration',
--                    'method_declaration',
--                    'if_statement',
--                    'for_statement',
--                    'switch_statement',
--                    'select_statement',
--                    'type_declaration',
--                    'struct_type',
--                    'interface_type',
--                },
--                -- For other languages, you can add similar patterns
--                lua = {
--                    'function_declaration',
--                    'function_definition',
--                    'if_statement',
--                    'for_statement',
--                    'while_statement',
--                },
--            },
--        })
--    end,
--}
