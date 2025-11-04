-- Only reason to use snacks is to have quickfile, buffer delete, explorer and git blame line. The indent animate is disturbing
-- Note for explorer to install you should have fd or fdfind.
--      For Ubuntu use: sudo apt install fd-find. Check fd --version
--      For RHEL: Usually has its installed automatically. Check fd --version
return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = true,
    --event = "VeryLazy",  -- Will definitely load after startup completes, so commented out
    -- For dashboard to work we have to set lazy to false and event to VimEnter
    --lazy = false,
    --event = "VimEnter",  -- Load on Vim startup
    -- Finally change dashboard enabled to true
    ---@type snacks.Config
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        bigfile = { enabled = true },    -- Ensure not to load lsp or diagnostics if file size is greater than 1.5MB
        dashboard = { enabled = false }, -- This enables default welcome homescreen where you can see recent files etc.
        explorer = {
        -- Inside the explorer you can do the following:
        -- Single file operations:
            -- m on a single file (no selection) → renames the file
            -- c on a single file (no selection) → prompts for new name to copy to
            -- r → rename current file
            -- d → delete current/selected files
        -- Copying and moving files:
            -- Select files with <Tab> or visual mode
            -- Press y to yank file paths to register
            -- Navigate to target directory
            -- Press p to paste (copies files from register)
        -- Other file operations:
            -- a → Add new file or directory (directories end with /)
            -- d → Delete files (uses system trash if available, see :checkhealth snacks)
            -- o → Open file with system application
            -- u → Update/refresh the file tree
        -- Navigation:
            -- <CR> or l → Open file or toggle directory
            -- h → Close directory
            -- <backspace> → Go up one directory
            -- . → Focus on current directory (set as cwd)
            -- H → Toggle hidden files
            -- I → Toggle ignored files (from gitignore)
            -- Z → Close all directories
            enabled = true,       -- Adds a tree based home structure
            replace_netrw = false -- Replace netrw with snacks explore False: Opens the folder in netrw. True: Opens the folder in snacks explorerr
        },
        gh = { enabled = false }, -- Is disabled as PR is different account and copilot is different account hence gh doesn't work well
        indent = {
            --enabled = true,  -- Help with the line in the indentation for each code block
            enabled = false,            -- In true mode '|' will be there during copying
            only_scope = false,         -- True: Only show indent guides of the scope
            only_current = false
        },                              -- True: Only show indent guides of the current line
        input = { enabled = false },   -- Moves commandline to center like a dialogue box
        lazygit = { enabled = false }, -- We have to explicitly install lazygit and have it in path for this to work
        notifier = { enabled = false },
        picker = { 
            -- This is the expanded version of ivy layout.
            enabled = true,
            layout = {
                layout = {
                    box = "vertical",
                    backdrop = false,
                    row = -1,
                    width = 0,
                    height = 0.5, -- For ivy its 0.4
                    border = "top",
                    title = " {title} {live} {flags}",
                    title_pos = "left",
                    { win = "input", height = 1, border = "bottom" },
                    {
                        box = "horizontal",
                        { win = "list", border = "none" },
                        { win = "preview", title = "{preview}", width = 0.5, border = "left" }, -- For ivy width is 0.6. Use <M-w> to toggle preview
                    },
                },
            },
        },   -- So much picking ability for colour and file picking
        profiler = { enabled = false }, -- Its a profiler only for lua, so not needed
        quickfile = { enabled = true }, -- Ensure that buffer loads first if there are only one file.
        scratch = { enabled = false }, -- Temporary create a floating window to test lua code
        -- Unable to disable the indent animate and its disturbing. Looks like a bug in snacks.nvim
        -- Hence settng the indent animate to false
        animate = { enabled = false,   -- Disable animations for performance e.g. indent lining won't animate
            style = "out",
            easing = "linear", -- Easing for the input box},
            duration = {
                step = 1,
                total = 1,
            },
        },
        scope = { enabled = false },
        scroll = { enabled = false },-- Animates the slow scrolling during jump and scroll bar. Its slow so disabled
        statuscolumn = { enabled = false },
        words = { enabled = false }, -- This if for LSP to show what ever faster. We are trying to do lazy here, so not needed
    },
    keys = {
        -- Commenting the snacks buffer due to 2 reasons as follows
        -- 1. Telescope gives the same function
        -- 2. <leader>b is used during diffview open files
        --{ "<leader>b", function() Snacks.picker.buffers() end, desc = "Buffers" }, -- Even with picker disabled this works
        { "<M-e>", function() Snacks.explorer() end, desc = "File Explorer", mode = "n" },
        { "<leader>bD", function() Snacks.bufdelete() vim.notify("Removed opened file from buffer") end, desc = "Deleted opened file from buffer", mode = "n" },
        { "<leader>bd", function() Snacks.bufdelete.other() vim.notify("Removed all other buffers") end, desc = "Delete everyone else in the buffer", mode = "n" },
        { "<leader>gB", function() Snacks.git.blame_line() end, desc = "Blame line with full details", mode = "n" },
        { "<leader>sp", function() Snacks.picker() end, desc = "Snacks all the pickers", mode = "n" },
        { "<leader>sf", function() Snacks.picker.files() end, desc = "Snacks Find files", mode = "n" },
        { "<leader>sb", function() Snacks.picker.git_branches() end, desc = "Snacks Find files", mode = "n" },
        { "<leader>sg", function() Snacks.picker.grep() end, desc = "Snacks Grep word", mode = "n" },
        { "<leader>sr", function() Snacks.picker.resume() end, desc = "Snacks picker resume", mode = "n" },
        { "<leader>su", function() Snacks.picker.undo() end, desc = "Snacks undo tree", mode = "n" },
        { "<leader>sl", function() Snacks.picker.lines() end, desc = "Snacks picker in a file matching string in all the lines", mode = "n" },
        { "<leader>sd", function() Snacks.picker.git_diff() end, desc = "Snacks list git diff", mode = "n" },
        { "<leader>se", function() Snacks.picker.icons() end, desc = "Snacks picker for icons and emoji", mode = "n" },
        { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Snacks picker for the occurance of the word under cursor across CWD", mode = "n" },
        { "<leader>sl", function() Snacks.picker.git_log_line() end, desc = "Snacks for viewing git log line details with commit details", mode = "n" },
        { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Snacks picker for all defined keymaps", mode = "n" },
    },
}
