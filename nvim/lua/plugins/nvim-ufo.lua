return {
    'kevinhwang91/nvim-ufo',
    lazy = false,
    dependencies = { 'kevinhwang91/promise-async' },
    opts = {
        provider_selector = function()
            return { 'treesitter', 'indent' }
        end,
    },
    keys = {
        { 'fc', '<cmd>foldclose<cr>' },
        { 'ff', '<cmd>foldopen<cr>' },
        {
            mode = 'v',
            'fc',
            ":'<,'>foldclose<cr>",
        },
        {
            mode = 'v',
            'ff',
            ":'<,'>foldopen<cr>",
        },
    },
}
