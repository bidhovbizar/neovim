local M = {}

-- Help content for netrw commands
local help_content = {
    "Netrw Help Commands",
    "═══════════════════",
    "File Operations:",
    "  %     - Create a new file (prompts for filename)",
    "  d     - Create a new directory/folder (prompts for directory name)",
    "  D     - Delete the file or directory under the cursor (prompts for confirmation)",
    "  R     - Rename/move the file or directory under the cursor",
    "  mf    - Mark the files",
    "  mu    - Unmark the files",
    "  mc    - Copy marked files to target directory",
    "  mm    - Move marked files to target directory",
    "  mx    - Execute marked files",
    "Navigation:",
    "  -     - Go up one directory",
    "  u     - Go back in history",
    "  U     - Go forward in history",
    "View Options:",
    "  i     - Cycle through different view types (thin/long/wide/tree)",
    "  s     - Select sorting method (name/time/size/extension)",
    "  r     - Reverse sort order",
    "  gh    - Toggle hidden files",
    "  a     - Toggle between normal and hiding mode",
    "  t     - Enter file in new tab",
    "  v     - Enter file in new vertical split",
    "  o     - Enter file in new horizontal split",
    "  p     - Preview file in split window",
    "  x     - Execute file with system default application",
    "Bookmarks:",
    "  mb    - Bookmark current directory",
    "  gb    - Go to bookmark",
    "Other:",
    "  qf    - Display file info",
    "  qF    - Mark files using shell-style glob",
    "  I     - Toggle banner display",
    "  O     - Obtain file (like wget)",
    "  <C-l> - Refresh directory listing",
    "  <C-h> - Edit file/directory hiding list",
    "  <leader>h     - Show this help",
    "",
    "Press 'q' or <Esc> to close this help window"
}

-- Create floating window with help content
function M.show_help()
    -- Calculate window dimensions
    local width = 60
    local height = #help_content + 2
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    -- Create buffer for help content
    local buf = vim.api.nvim_create_buf(false, true)

    -- Set buffer content
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, help_content)

    -- Make buffer read-only
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')

    -- Create floating window
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
        title = ' Netrw Help ',
        title_pos = 'center'
    })

    -- Set window options
    vim.api.nvim_win_set_option(win, 'wrap', false)
    vim.api.nvim_win_set_option(win, 'cursorline', false)

    -- Set up key mappings to close the window
    local close_win = function()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end

    -- Key mappings for closing the help window
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '', {
        callback = close_win,
        noremap = true,
        silent = true
    })

    vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '', {
        callback = close_win,
        noremap = true,
        silent = true
    })

    -- Auto-close on focus lost
    vim.api.nvim_create_autocmd('WinLeave', {
        buffer = buf,
        callback = close_win,
        once = true
    })
end

-- Autocommand to set up netrw key mappings when entering netrw buffer
-- Setup netrw help keybinding
local function setup_netrw_help()
    vim.api.nvim_create_autocmd('FileType', {
        pattern = 'netrw',
        callback = function()
            -- Set up the help keybinding for netrw buffers
            vim.api.nvim_buf_set_keymap(0, 'n', '<leader>h', '', {
                callback = function()
                    require('basicConfig.netrwhelp').show_help()
                end,
                noremap = true,
                silent = true,
                desc = 'Show netrw help'
            })
        end,
        desc = 'Setup netrw help keybinding'
    })
end

-- Call the setup function
setup_netrw_help()

return M
