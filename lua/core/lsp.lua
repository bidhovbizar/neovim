-- Only enable LSPs when the appropriate filetype is detected
-- Using group variable to group all the lsp together in nvim_create_autocmd this ensure no duplicate call
local group = vim.api.nvim_create_augroup("LSPFileType", { clear = true })

-- Go
-- Install Go using sudo apt install go OR direct from dev.go and gopls using go install golang.org/x/tools/gopls@latest
-- Install gopls using go install golang.org/x/tools/gopls@latest
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
        vim.api.nvim_create_autocmd("InsertEnter", {  -- This will start the lsp server only when you enter insert mode
            buffer = 0,  -- Only for the current buffer
            once = true, -- Only once for the current buffer
            callback = function ()
            vim.lsp.start({
                name = "gopls",
                cmd = config.cmd,
                root_dir = vim.fs.dirname(vim.fs.find(config.root_markers, {upward = true})[1]),
                settings = config.settings,
            })
            end,
        })
    end,
})

-- Python
-- Install python using sudo apt install python
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
        vim.api.nvim_create_autocmd("InsertEnter", {  -- This will start the lsp server only when you enter insert mode
            buffer = 0,  -- Only for the current buffer
            once = true, -- Only once for the current buffer
            callback = function ()
                vim.lsp.start({
                    name = "pyright",
                    --name = "basedpyright",  -- investigate and decide which one to use
                    cmd = config.cmd,
                    root_dir = vim.fs.dirname(vim.fs.find(config.root_markers, {upward = true})[1]),
                    settings = config.settings,
                })
            end,
        })
    end,
})

-- Lua
-- This would usually comes with neovim
vim.api.nvim_create_autocmd("FileType", {
    pattern = "lua", 
    group = group,
    callback = function()
        -- We fetch the values written in ~/.config/nvim/lua/lsp/lua_ls.lua into variable 'config'
        local config = require("lsp.lua_ls")
        -- Only one of the below section should be uncommented at a time
        --  Section 1
        --vim.lsp.enable("lua_ls")  -- This won't attach anything as nvim wont attach later
        -- Section 2
        -- The following will look for the lsp server lua_ls so install lua-language-server in your server manually and only then uncomment the following start()
        vim.api.nvim_create_autocmd("InsertEnter", {  -- This will start the lsp server only when you enter insert mode
            buffer = 0,  -- Only for the current buffer
            once = true, -- Only once for the current buffer
            callback = function ()
                vim.lsp.start({
                    name = "lua_ls",
                    cmd = config.cmd,
                    root_dir = vim.fs.dirname(vim.fs.find(config.root_markers, {upward = true})[1]),
                    settings = config.settings,
                    single_file_support = config.single_file_support,
                })
            end,
        })
    end,
})

-- Bash
-- This would be installed along with the OS and bash or zsh shell is available
vim.api.nvim_create_autocmd("FileType", {
    pattern = {"sh", "bash", "zsh"},
    group = group,
    callback = function()
        -- We fetch the values written in ~/.config/nvim/lua/lsp/bash_ls.lua into variable 'config'
        local config = require("lsp.bash_ls")
        -- Only one of the below section should be uncommented at a time
        --  Section 1
        --vim.lsp.enable("bash_ls")  -- This won't attach anything as nvim wont attach later
        -- Section 2
        -- The following will look for the lsp server bash-language-server so install it manually and only then uncomment the following start()
        -- Uncomment the following only after installing bash-language-server and shellcheck
        -- Install bash-language-server using npm install -g bash-language-server
        -- Install shellcheck using sudo apt install shellcheck
        vim.api.nvim_create_autocmd("InsertEnter", {  -- This will start the lsp server only when you enter insert mode
            buffer = 0,  -- Only for the current buffer
            once = true, -- Only once for the current buffer
            callback = function ()
                vim.lsp.start({
                    name = "bash_ls",
                    cmd = config.cmd,
                    root_dir = vim.fs.dirname(vim.fs.find(config.root_markers, {upward = true})[1]),
                    settings = config.settings,
                    single_file_support = config.single_file_support,
                })
            end,
        })
    end,
})

-- Starts the LSPs for the current buffer as soon as nvim is started
--vim.lsp.enable({
--    "gopls",
--    "pyright",
--    "lua_ls",
--    "bash_ls",
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

------------------------------------------------------------------------ 
-- Enable inlay hints for the current buffer
-- This will pop up hints while filling the function with arguments. This only helps if the function definition has inlay hints e.g. add(x:int,y:int) -> int
local bufnr = vim.api.nvim_get_current_buf()
if vim.lsp.inlay_hint then
  vim.lsp.inlay_hint.enable(true, {bufnr = bufnr})
end

-- Toggle inlay hints for current buffer
vim.keymap.set("n", "<leader>ti", function()
  local buf = vim.api.nvim_get_current_buf()
  print("Toggle inlay hints called for buffer:", buf)
  
  local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = buf })
  print("Currently enabled:", enabled)
  print(vim.inspect(enabled))

  local new_state = not enabled
  print("Setting inlay hints to:", new_state)
  
  vim.lsp.inlay_hint.enable(new_state, { bufnr = buf })
end, { desc = "Toggle Inlay Hints" })
