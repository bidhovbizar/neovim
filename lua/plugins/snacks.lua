-- Only reason to use snacks is to have quickfile, buffer list and explorer. The indent animate is disturbing
-- Note for explorer to install you should have fd or fdfind.
--      For Ubuntu use: sudo apt install fd-find. Check fd --version
--      For RHEL: Usually has its installed automatically. Check fd --version
return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        bigfile = { enabled = true }, -- Ensure not to load everything if file size is greater than 1.5MB
        dashboard = { enabled = false }, -- Removed the homescreen
        explorer = { enabled = true, -- Adds a tree based home structure
            replace_netrw = false}, -- False: Opens the folder in netrw. True: Opens the folder in snacks explorer
        -- Unable to disable the indent animate and its disturbing. Looks like a bug in snacks.nvim
        -- Hence settng the indent animate to false
        indent = {
            --enabled = true,  -- Help with the line in the indentation for each code block
            enabled = false, -- In true mode '|' will be there during copying
            only_scope = false,  -- True: Only show indent guides of the scope
            only_current = false}, -- True: Only show indent guides of the current line
        -- Set to false to ensure there are no distractions
        animate = { enabled = false, -- Disable animations for performance e.g. indent lining won't animate
            style = "out",
            easing = "linear", -- Easing for the input box},
            duration = {
                step = 1,
                total = 1,
            },
        },
        scope = { enabled = false },
        input = { enabled = false },
        picker = { enabled = false }, -- So much picking ability for colour and file picking
        notifier = { enabled = false },
        quickfile = { enabled = true }, -- Only reason to use snacks is to have quickfile
        scroll = { enabled = false },
        statuscolumn = { enabled = false },
        words = { enabled = false }, -- This if for LSP to show what ever faster. We are trying to do lazy here, so not needed
    },
    keys = {
        { "<leader>b", function() Snacks.picker.buffers() end, desc = "Buffers" }, -- Even with picker disabled this works
        { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
    },
}
