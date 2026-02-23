-- Set the path where lazy.nvim will be installed
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'

-- Check if lazy.nvim is already installed
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    -- Repository URL for lazy.nvim
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    -- Clone lazy.nvim from GitHub
    local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
    -- If cloning fails, show error
    if vim.v.shell_error ~= 0 then
        error('Error cloning lazy.nvim:\n' .. out)
    end
end

-- Prepend lazy.nvim to runtime path
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim with configuration
require("lazy").setup({ import = "plugins" }, {
    install = {
        missing = true,             -- Install missing plugins automatically
        colorscheme = { "gruvbox" } -- Set default colorscheme
    },
    checker = {
        enabled = false, -- Disable automatic plugin update checking
        notify = false,  -- Disable notifications for update checking
    },
    change_detection = {
        enabled = true,  -- Enable configuration file change detection automatically otherwise, if its false then :Lazy reload <plugin> is required
        notify = false,  -- Disable notifications for change detection
    },
    rocks = {
        enabled = false, -- Disables luarocks completely. luarocks is a package manager for Lua modules.
    },
    concurrency = vim.uv.available_parallelism(), -- Limit the number of concurrent tasks
    ui = {
        -- border = "rounded" -- Optional: set UI border style
    },
    performance = {
        cache = {
            enabled = true,        -- Enable caching for faster loads
        },
        reset_packpath = true,     -- Clean up packpath for performance
        rtp = {
            reset = true,          -- Reset runtime path for cleaner loading
            disabled_plugins = {
                "gzip",            -- Disable gzip plugin
                "tarPlugin",       -- Disable tar archive plugin
                "tohtml",          -- Disable HTML conversion
                "zipPlugin",       -- Disable zip archive plugin
                "2html_plugin",    -- Disable HTML conversion plugin
                "getscript",       -- Disable script downloading
                "getscriptPlugin", -- Disable script downloading plugin
                "rrhelper",        -- Disable remote helper
                "vimball",         -- Disable Vimball archive handling
                "vimballPlugin",   -- Disable Vimball plugin
            },
        },
    },
})
