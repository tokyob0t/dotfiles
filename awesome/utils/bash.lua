local lgi = require("lgi")
local GLib = lgi.require("GLib", "2.0")
local Gio = lgi.require("Gio", "2.0")

local awful = require("awful")

local _BASH = {}

---@param cmd string
---@return string
local parse_cmd = function(cmd)
	return string.format([[sh -c '%s']], cmd)
end

---@param cmd string
---@param callback? function
_BASH.run = function(cmd, callback)
	cmd = parse_cmd(cmd)
	awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr, reason, exit_code)
		if callback then
			if exit_code == 0 then
				callback(true)
			else
				callback(false)
			end
		end
	end)
end

---@param cmd string
---@param callback? function
---@return nil
_BASH.get_output = function(cmd, callback)
	cmd = parse_cmd(cmd)

	awful.spawn.easy_async(cmd, function(stdout, stderr, _, exit_code)
		if callback then
			if exit_code == 0 then
				return callback(stdout)
			else
				return callback(stderr)
			end
		end
	end)
end

---@param cmd string
---@param stdout_callback? function
---@param stderr_callback? function
_BASH.popen = function(cmd, stdout_callback, stderr_callback)
	cmd = parse_cmd(cmd)
	awful.spawn.with_line_callback(cmd, {
		stdout = stdout_callback,
		stderr = stderr_callback,
	})
end

---@param path string
---@return boolean
_BASH.file_exists = function(path)
	if path then
		return GLib.file_test(path, GLib.FileTest.EXISTS)
	else
		return false
	end
end

---@param path string
---@return boolean
_BASH.dir_exists = function(path)
	if path then
		return GLib.file_test(path, GLib.FileTest.IS_DIR)
	else
		return false
	end
end

---@param file_or_path string | Gio.File
---@return string?
_BASH.cat = function(file_or_path)
	if type(file_or_path) == "string" then
		return _BASH.cat(Gio.File.new_for_path(file_or_path))
	elseif type(file_or_path) == "userdata" then
		local _, content, _ = file_or_path:load_contents()
		return content
	end
end

---@param file_or_path string | Gio.File
---@return nil
_BASH.cat_async = function(file_or_path, callback)
	if type(file_or_path) == "string" then
		return _BASH.cat_async(Gio.File.new_for_path(file_or_path), callback)
	elseif type(file_or_path) == "userdata" then
		file_or_path:load_contents_async(nil, function(_, task)
			local _, content, _ = file_or_path:load_contents_finish(task)
			return callback(content)
		end)
	end
end

---@param args any
---@return Gio.FileMonitor
_BASH.monitor_file = function(args) end

return _BASH
