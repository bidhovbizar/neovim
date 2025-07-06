return {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = "Telescope",
    keys = { "<leader>f" }, -- Load when any key starting with <leader>f is pressed
    config = function()
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
        vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
        -- To clear any file in the buffer do :ls to find files or <leader>fb then to remove do :bd <buffer_number> e.g. :bd 33
        -- To clear all buffers do :bwipeout
        vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = 'Telescope oldfiles' })
        vim.keymap.set('n', '<leader>ft', builtin.git_files, { desc = 'Telescope oldfiles' })
        vim.keymap.set('n', '<leader>fH', builtin.help_tags, { desc = 'Telescope help tags' })
    end
}
