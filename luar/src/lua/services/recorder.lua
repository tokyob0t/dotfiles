local gobject = require('lua.services.gobject')
local notify = require('lua.utils.notify')
local Process = require('astal.process').Process
local exec_async, exec = astal.exec_async, astal.exec
local async_exec = require('astal.process').async_exec
local async_write_file = require('astal.file').async_write_file

local Recordings = GLib.get_home_dir() .. '/Videos/Recordings'
local Screenshots = GLib.get_home_dir() .. '/Pictures/Screenshots'

local now = function() return os.date('%Y-%m-%d_%H-%M-%S') end

local mkdir = function(path) return async_exec { 'mkdir', '-p', path } end
local slurp = function(...) return async_exec { 'slurp', ... } end
local grim = function(...) return async_exec { 'grim', ... } end
local wl_copy = function(...) return async_exec { 'wl-copy', ... } end
local wf_recorder = function(...) return Process.new({ 'wf-recorder', '-x', 'yuv420p', ... }, 'r') end

---@class LuaRecorderService: GObject.Object
---@field recording boolean r
---@field private priv { process: AstalLuaProcess, recording: boolean, file: string }
local Recorder = gobject.new('LuaRecorder', {}, {
    recording = { 'boolean', 'r' },
})

---@param area? string
function Recorder:start(area)
    if self.recording then return end

    self.priv.file = Recordings .. '/' .. now() .. '.mp4'
    mkdir(Recordings)

    local args = { '-f', self.priv.file }

    if area then table.push(args, '-g', area) end

    self.priv.process = wf_recorder(table.unpack(args))
    self.priv.recording = true
    self:notify('recording')
end

function Recorder:stop()
    if not self.recording then return end

    self.priv.process:signal('SIGINT')
    self.priv.process = nil
    self.priv.recording = false
    self:notify('recording')

    if not GLib.file_test(self.priv.file, 'EXISTS') then return end

    notify {
        appname = 'Recorder',
        summary = 'Screen Record',
        body = self.priv.file,
        icon = 'video-x-generic-symbolic',
        actions = {
            ['Show in files'] = function() exec_async('xdg-open ' .. Recordings) end,
            View = function() exec_async('xdg-open ' .. self.priv.file) end,
            Delete = function() exec_async { 'rm', self.priv.file } end,
        },
    }
end

---@param full? boolean
Recorder.screenshot = async(function(_, full)
    local file = Screenshots .. '/' .. now() .. '.png'

    mkdir(Screenshots)

    local args = {}

    if not full then
        local geometry = slurp()

        if not geometry then return end

        table.push(args, '-g', geometry)
    end

    table.push(args, file)

    grim(table.unpack(args))

    wl_copy('--type', 'text/uri-list', 'file://' .. file)

    notify {
        appname = 'Recorder',
        summary = 'Screenshot',
        body = file,
        icon = 'image-x-generic-symbolic',
        actions = {
            ['Show in files'] = function() exec_async { 'xdg-open', Screenshots } end,
            View = function() exec_async { 'xdg-open', file } end,
            Delete = function() exec_async { 'rm', file } end,
        },
        hints = { 'string:image-path:' .. file },
    }
end)

function Recorder:_init() self.priv.recording = false end

local _instance

return {
    ---@return LuaRecorderService
    get_default = function()
        if _instance then return _instance end

        _instance = Recorder()

        return _instance
    end,
}
