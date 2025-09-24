return {
    {
        -- For theme of nvim
        --"folke/tokyonight.nvim",
        "ellisonleao/gruvbox.nvim",
        priority = 1000, -- Ensure this loads before lualine
        lazy = false,    -- Make sure we load this during startup if it is your main colorscheme
        config = function()
            vim.cmd.colorscheme "gruvbox"
        end
    },
    {
        -- For the status line or lua line
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy", -- Defer loading until after startup
        --priority = 700, -- Ensure this loads before lualine
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            -- Add update throttling to prevent frequent refreshes
            options = {
                theme = 'gruvbox',
                refresh = {
                    statusline = 1000,  -- Refresh every 1000ms instead of default
                    tabline = 1000,
                    winbar = 1000,
                },
            },
            sections = {
                lualine_a = { 'mode' },                -- NORMAL, INSERT, etc.
                --lualine_b = { },              -- Setting the branch to none to avoid loading  
                --lualine_c = { },              -- Setting the filepath to none to avoid loading
                lualine_b = { 'branch' },              -- Git branch; But will be slow for network-mounted directories like ADS
                lualine_c = {
                    { 'filename', path = 1 },          -- 0: only file name; 1: path relative
                },
                lualine_x = {}, -- remove 'diff', 'diagnostics', 'filetype', 'encoding', etc.
                lualine_y = {'progress'},               -- remove progress %
                lualine_z = { 'location' },            -- line/column
            },
        },
    },
}
