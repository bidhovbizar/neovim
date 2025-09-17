return {
    { -- Git plugin - lazy load to prevent startup issues
        'tpope/vim-fugitive',
        cmd = { 'Git', 'Git blame', 'Git push', 'Git pull', 'Gdiff' },
        keys = {
            { '<leader>gb', '<cmd>Git blame<cr>', desc = 'Git blame' },
            { '<leader>gd', '<cmd>Gvdiffsplit!<cr>', desc = 'Git 3-way diff' },
            { '<leader>gh', '<cmd>diffget //2<cr>', desc = 'Get from HEAD' },
            { '<leader>gm', '<cmd>diffget //3<cr>', desc = 'Get from merge branch' },
        },
    },
}
