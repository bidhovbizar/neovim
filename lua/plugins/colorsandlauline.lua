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
            theme = 'gruvbox',
            sections = {
                lualine_a = { 'mode' },                -- NORMAL, INSERT, etc.
                lualine_b = { 'branch' },              -- Git branch
                lualine_c = {
                    { 'filename', path = 1 },          -- full absolute path
                },
                lualine_x = { 'diff', 'diagnostics' }, -- remove filetype, encoding, etc.
                --lualine_y = {},               -- remove progress %
                lualine_z = { 'location' },            -- line/column
            },
        }
    },
}
