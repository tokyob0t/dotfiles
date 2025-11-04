return {
    'nvim-telescope/telescope.nvim',
    version = '*',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
        { '<leader><Tab>', '<cmd>Telescope buffers<cr>' },
        { '<leader>.', '<cmd>Telescope find_files<cr>' },
        { '<leader>,', '<cmd>Telescope live_grep<cr>' },
    },
}
