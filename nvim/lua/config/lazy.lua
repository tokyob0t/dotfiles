local os_name = vim.loop.os_uname().sysname
local lazypath

if vim.env.LAZY_PATH then
    lazypath = vim.env.LAZY_PATH
else
    if string.find(os_name, 'Windows') then
        lazypath = vim.fn.stdpath('data') .. '\\lazy\\lazy.nvim'
    else
        lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
    end
end

if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable',
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
    spec = {
        { import = 'plugins' },
    },
    install = { colorscheme = { 'oxocarbon' } },
})
