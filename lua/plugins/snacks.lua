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
    explorer = { enabled = true }, -- Adds a tree based home structure
    indent = { enabled = true },  -- Help with the line in the indentation
    input = { enabled = false },
    picker = { enabled = false }, -- So much picking ability for colour and file picking
    notifier = { enabled = false },
    quickfile = { enabled = true },
    scope = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    words = { enabled = false }, -- This if for LSP to show what ever faster. We are trying to do lazy here, so not needed
  },
keys = {
    { "<leader>b", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
},
}
