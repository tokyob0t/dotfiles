for _, fn in ipairs {
    require('lua.daemons.lockscreen'),
    require('lua.daemons.clipboard'),
    require('lua.daemons.swww'),
    require('lua.daemons.portal'),
    require('lua.daemons.theme'),
    require('lua.daemons.battery'),
} do
    fn()
end
