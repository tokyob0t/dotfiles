return {
    'terrortylor/nvim-comment',
    --lazy = false,
    cmd = { 'CommentToggle' },
    config = function()
        require('nvim_comment').setup({
            comment_empty = false,
            create_mappings = false,
        })
    end,
    keys = {
        { '<leader>\\', '<cmd>CommentToggle<cr>' },
        { mode = 'v', '<leader>\\', ":'<,'>CommentToggle<cr>" },
    },
}
