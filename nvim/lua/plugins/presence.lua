return {
    'vyfor/cord.nvim',
    build = ':Cord update',
    opts = {

        text = {
            editing = function(opts)
                return string.format(
                    'Editing %s - %s:%s',
                    opts.filename,
                    opts.cursor_line,
                    opts.cursor_char
                )
            end,
        },
    },
}
