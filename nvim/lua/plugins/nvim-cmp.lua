return {
    'hrsh7th/nvim-cmp',
    dependencies = {
        'neovim/nvim-lspconfig',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-cmdline',
        --
        'L3MON4D3/LuaSnip',
        'saadparwaiz1/cmp_luasnip',
    },
    config = function()
        local cmp = require('cmp')

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                end,
            },
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip', option = { show_autosnippets = true } },
                { name = 'buffer' },
                { name = 'path' },
            }),
            window = {
                completion = {
                    winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,Search:None',
                    col_offset = -3,
                    side_padding = 0,
                },
            },
            formatting = {
                fields = { 'kind', 'abbr', 'menu' },
                format = function(entry, vim_item)
                    vim_item.kind = KindIcons[vim_item.kind]
                        or KindIcons['Text']
                    vim_item.menu = ({
                        path = '[Path]',
                        buffer = '[Buffer]',
                        nvim_lsp = '[LSP]',
                        luasnip = '[LuaSnip]',
                        --nvim_lua = '[Lua]',
                        latex_symbols = '[LaTeX]',
                    })[entry.source.name]

                    vim_item.menu = vim_item.menu
                        or string.format(
                            '[%s]',
                            string.gsub(entry.source.name, '^%l', string.upper)
                        )

                    return vim_item
                end,
            },
            mapping = cmp.mapping.preset.insert({
                --["<C-b>"] = cmp.mapping.scroll_docs(-4),
                --["<C-f>"] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-x>'] = cmp.mapping.abort(),
                ['<CR>'] = cmp.mapping.confirm({ select = false }),
                ['<Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    else
                        fallback()
                    end
                end),
                ['<S-Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    else
                        fallback()
                    end
                end),
            }),
            experimental = {
                ghost_text = true,
            },
        })
        cmp.setup.cmdline({ '/', '?', ':' }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = 'buffer' },
                { name = 'path' },
                { name = 'cmdline' },
            },
        })
    end,
}
