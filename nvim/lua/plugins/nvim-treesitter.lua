return {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    config = function()
        require('nvim-treesitter.configs').setup({
            auto_install = true,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
                disable = function(_, buffer)
                    local max_filesize = 100 * 1024
                    local ok, stats = pcall(
                        vim.loop.fs_stat,
                        vim.api.nvim_buf_get_name(buffer)
                    )

                    if ok and stats and stats.size > max_filesize then
                        return true
                    end
                end,
            },
        })
    end,
}
