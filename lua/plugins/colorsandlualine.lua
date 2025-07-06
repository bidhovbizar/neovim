return {
    {
        -- For theme of nvim
        --"folke/tokyonight.nvim",
        "ellisonleao/gruvbox.nvim",
        config = function()
            vim.cmd.colorscheme "gruvbox"
        end
    },
    {
        -- For the status line or lua line
        "nvim-lualine/lualine.nvim",
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
                lualine_b = { 'branch' },              -- Git branch
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
