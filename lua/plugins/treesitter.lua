-- To use treesitter run :InspectTree you should see another window with all details
return {
    'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
    config = function()
        local configs = require("nvim-treesitter.configs")
        configs.setup({
            -- Hightlights the code and replace regex-based vim highlighting
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false, -- This is to ensure that there is no clash between vim and treesitter
            },
            ensure_installed = {
                "lua",
                "go",
                "python",
                "bash",
                "json",
                "yaml",
                "markdown",
                "dockerfile",
                "make",
                "toml",
            },
            indent = {
                enable = false, -- Set this to false as this overrides vim's indendation which is better
            },
            autotag = {
                enable = true
            },
            auto_install = false,
        })
    end
}
