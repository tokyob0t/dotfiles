local servers = {
    'clangd', -- C/C++
    'ruff', -- Python
    'pylsp',
    'jsonls', -- Json
    -- TypeScript/JavaScript
    'ts_ls',
    'biome',
    -- 'svelte', -- Svelte
    -- 'volar',
    'biome',
    'emmet_language_server',
    -- 'cssls', -- CSS/SCSS
    'somesass_ls', -- CSS/SCSS
    'tailwindcss',
    -- 'css_variables',
    -- 'cssmodules_ls',
    'bashls', -- Bash
    'lua_ls', -- Lua
    'fennel_ls',
    -- 'fennel_language_server',
    'rust_analyzer', -- Rust
    'perlpls', -- Perl
    'marksman', -- Markdown
    'vala_ls', -- Vala
    'nil_ls', -- Nix
    'lemminx', -- xml
    'mesonlsp', -- meson
}

return {
    'neovim/nvim-lspconfig',
    config = function()
        local lspconfig = require('lspconfig')
        local capabilities = require('cmp_nvim_lsp').default_capabilities()
        capabilities.textDocument.completion.completionItem.snippetSupport =
            true
        local navic = require('nvim-navic')

        for _, lsp in ipairs(servers) do
            local opts = {
                capabilities = capabilities,
                on_attach = function(client, n)
                    if client.server_capabilities.documentSymbolProvider then
                        navic.attach(client, n)
                    end
                end,
            }

            if lsp == 'emmet_language_server' then
                opts.init_options = { showSuggestionsAsSnippets = true }
            end

            lspconfig[lsp].setup(opts)
        end
    end,
}
