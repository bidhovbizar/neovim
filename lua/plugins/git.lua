return {
    { -- Git plugin - lazy load to prevent startup issues
        'tpope/vim-fugitive',
            cmd = { 'Git', 'Gstatus', 'Gblame', 'Gpush', 'Gpull', 'Gdiff' },
            keys = {
                { '<leader>gb', '<cmd>Git blame<cr>', desc = 'Git blame' },
            },
    },
}
