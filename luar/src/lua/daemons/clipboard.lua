local Process = require('astal.process').Process
local settings = require('lua.utils.settings')

local max_history = settings('clipboard-max-history', 'u')
local max_item_size = settings('clipboard-max-item-size', 'u')
local history, set_history = settings('clipboard-history', 'a(ts)')

local function is_empty(str) return string.gsub(str, '%s+', '') == '' end
local function is_duplicated(str)
    for _, tuple in ipairs(history:get()) do
        if tuple[2] == str then return true end
    end
end

local function dont_exceeds() return (#history:get() + 1) <= max_history:get() end

return async(function()
    local p = Process.new({ 'wl-paste', '--type', 'text', '--watch', 'cat' }, 'r')
    local stdout_stream = Gio.DataInputStream.new(p.subprocess:get_stdout_pipe())

    for bytes in function() return stdout_stream:async_read_bytes(max_item_size:get()) end do
        local data = tostring(bytes:get_data(bytes:get_size()))

        if is_empty(data) or is_duplicated(data) or not dont_exceeds() then goto continue end

        set_history(table.append(history:get(), { os.time(), data }))

        ::continue::
    end
end)
