return {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    init = function()
        vim.api.nvim_create_user_command('ToggleFormat', function()
            local global_state = vim.g.disable_autoformat
            local buffer_state = vim.b.disable_autoformat
            if global_state or buffer_state then
                vim.b.disable_autoformat = false
            else
                vim.b.disable_autoformat = true
            end
        end, {
            desc = 'Toggle autoformat-on-save',
        })
    end,
    opts = {
        formatters_by_ft = {
            c = { 'clang-format' },
            ['c++'] = { 'clang-format' },
            lua = { 'stylua' },
            fennel = { 'fnlfmt' },
            python = {
                'isort',
                'ruff_fix', -- To fix auto-fixable lint errors.
                'ruff_format', -- To run the Ruff formatter.
            },
            javascript = { 'biome' },
            typescript = { 'biome' },
            -- tsx = { 'biome' },
            json = { 'biome' },
            sass = { 'prettierd' },
            scss = { 'prettierd' },
            nix = { 'nixpkgs-fmt', 'nixfmt' },
            sh = { 'beautysh' },
        },
        format_after_save = function(bufnr)
            if vim.b[bufnr].disable_autoformat then
                return
            end
            return { timeout_ms = 1000, lsp_format = 'fallback' }
        end,
    },
}
