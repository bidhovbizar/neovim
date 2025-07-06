return {
    'nvim-treesitter/nvim-treesitter',
    version = "v0.9.0", -- Cannot use the latest as its incompatible with nvim 10.0.0
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
	    autotage = {
		enable = true
	    },
	    auto_install = false,
	})
    end
}
