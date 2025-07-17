-- Only enable LSPs when the appropriate filetype is detected
-- Using group variable to group all the lsp together in nvim_create_autocmd this ensure no duplicate call
local group = vim.api.nvim_create_augroup("LSPFileType", { clear = true })

-- Go
-- Install Go using sudo apt install go OR direct from dev.go and gopls using go install golang.org/x/tools/gopls@latest
vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    group = group,
    callback = function()
        -- We fetch the values written in ~/.config/nvim/lua/lsp/gopls.lua into variable 'config'
        local config = require("lsp.gopls")
        -- Only one of the below section should be uncommented at a time
        --  Section 1
        --vim.lsp.enable("gopls")   -- This won't attach anything as nvim wont attach later
        -- Section 2
        -- Caveat: This will look for gopls package in your $PATH so install go and gopls in your server manually and only then uncomment the following start()
        vim.lsp.start({
            name = "gopls",
            cmd = config.cmd,
            root_dir = vim.fs.dirname(vim.fs.find(config.root_markers, {upward = true})[1]),
            settings = config.settings,
        })
    end,
})

-- Python
-- Install pyright using pip install pyright
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    group = group,
    callback = function()
        -- We fetch the values written in ~/.config/nvim/lua/lsp/pyright.lua into variable 'config'
        local config = require("lsp.pyright")
        -- Only one of the below section should be uncommented at a time
        --  Section 1
        --vim.lsp.enable("pyright")   -- This won't attach anything as nvim wont attach later
        -- Section 2
        -- Caveat: This will look for pyright package in your $PATH so install pyright in your server manually and only then uncomment the following start()
        vim.lsp.start({
            name = "pyright",
            --name = "basedpyright",  -- investigate and decide which one to use
            cmd = config.cmd,
            root_dir = vim.fs.dirname(vim.fs.find(config.root_markers, {upward = true})[1]),
            settings = config.settings,
        })
    end,
})

-- Lua
vim.api.nvim_create_autocmd("FileType", {
    pattern = "lua", 
    group = group,
    callback = function()
        -- We fetch the values written in ~/.config/nvim/lua/lsp/lua_ls.lua into variable 'config'
        vim.lsp.enable("lua_ls")  -- This won't attach anything as nvim wont attach later
        -- Only one of the below section should be uncommented at a time
        --  Section 1
        -- The following will look for the lsp server lua_ls so install lua-language-server in your server manually and only then uncomment the following start()
        --vim.lsp.start({
        --    name = "lua_ls",
        --    cmd = {"lua-language-server"},
        --    root_dir = vim.fs.dirname(vim.fs.find({".luarc.json", ".git"}, {upward = true})[1]),
        --})
    end,
})

-- Starts the LSPs for the current buffer as soon as nvim is started
--vim.lsp.enable({
--    "gopls",
--    "pyright",
--    "lua_ls"
--})

vim.diagnostic.config({
  --virtual_lines = true,  -- Uncomment this to enable virtual lines red colour for diagnostics
  virtual_text = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "✗ ",
      [vim.diagnostic.severity.WARN] = "⚠ ",
      [vim.diagnostic.severity.INFO] = "ℹ ",
      [vim.diagnostic.severity.HINT] = "➤ ",
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = "ErrorMsg",
      [vim.diagnostic.severity.WARN] = "WarningMsg",
    },
  },
})

-- Section to enable and disable diagnostics and toggle their display visibility
-- Global diagnostic state tracking
local diagnostics_enabled = false
local diagnostic_display_visible = true

-- Toggle diagnostics on/off
function toggle_diagnostics_enable()
  if diagnostics_enabled then
    vim.diagnostic.enable(false)
    diagnostics_enabled = false
    print("Diagnostics disabled")
  else
    vim.diagnostic.enable(true)
    diagnostics_enabled = true
    print("Diagnostics enabled")
  end
end

-- Toggle diagnostic display visibility
function toggle_diagnostic_display()
  if diagnostic_display_visible then
    vim.diagnostic.config({
      virtual_text = false,
      signs = false,
      underline = false,
    })
    diagnostic_display_visible = false
    print("Diagnostic display hidden")
  else
    vim.diagnostic.config({
      --virtual_lines = true,  -- Uncomment this to enable virtual lines red colour for diagnostics
      virtual_text = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = {
        border = "rounded",
        source = true,
      },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "✗ ",
          [vim.diagnostic.severity.WARN] = "⚠ ",
          [vim.diagnostic.severity.INFO] = "ℹ ",
          [vim.diagnostic.severity.HINT] = "➤ ",
        },
        numhl = {
          [vim.diagnostic.severity.ERROR] = "ErrorMsg",
          [vim.diagnostic.severity.WARN] = "WarningMsg",
        },
      },
    })
    diagnostic_display_visible = true
    print("Diagnostic display shown")
  end
end

-- Start with diagnostics disabled by default
vim.diagnostic.enable(false)

-- Diagnostic control keymaps
-- By default its disabled
vim.keymap.set('n', '<leader>de', toggle_diagnostics_enable, { desc = 'Enable diagnostics' })
vim.keymap.set('n', '<leader>dd', function() 
  vim.diagnostic.enable(false)
  print("Disable diagnostics ")
end, { desc = 'Disable diagnostics' })
-- Don't  toggle if diagnostics are already disabled
vim.keymap.set('n', '<leader>ds', toggle_diagnostic_display, { desc = 'Toggle diagnostic display' })

-- Show diagnostics in a floating window
vim.keymap.set("n","<leader>/", vim.diagnostic.open_float, { desc = "LSP: Open Diagnostic Float" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP: Hover Documentation" })
vim.keymap.set("n", "g2D", "<cmd>vsplit | lua vim.lsp.buf.declaration()<cr>", { desc = "LSP: Goto Declaration in vertical split" })
vim.keymap.set("n", "g2d", "<cmd>vsplit | lua vim.lsp.buf.definition()<cr>", { desc = "LSP: Goto Definition in Vertical Split" })
vim.keymap.set("n", "g2s", vim.lsp.buf.signature_help, { desc = "LSP: Signature Documentation" })
vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, { desc = "LSP: Code Action" })
vim.keymap.set("n", "<leader>ra", vim.lsp.buf.rename, { desc = "LSP: Rename all references" })
vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format, { desc = "LSP: Format" })

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
