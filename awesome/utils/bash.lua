local lgi = require("lgi")
local GLib = lgi.require("GLib", "2.0")
local Gio = lgi.require("Gio", "2.0")
local awful = require("awful")

---@class bash
bash = {}

---@param cmd string | string[]
---@param callback? function
bash.run = function(cmd, callback)
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

---@param cmd string | string[]
---@param callback? function
---@return nil
bash.get_output = function(cmd, callback)
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

---@param cmd string | string[]
---@param stdout_callback function?
---@param stderr_callback function?
---@param callback function?
bash.popen = function(cmd, stdout_callback, stderr_callback, callback)
	stdout_callback = stdout_callback or function() end
	stderr_callback = stderr_callback or function() end
	callback = callback or function() end
	awful.spawn.with_line_callback(cmd, {
		stdout = stdout_callback,
		stderr = stderr_callback,
		exit = callback,
	})
end

---@param path string
---@return boolean
bash.file_exists = function(path)
	if path then
		return GLib.file_test(path, GLib.FileTest.EXISTS)
	else
		return false
	end
end

---@param path string
---@return boolean
bash.dir_exists = function(path)
	if path then
		return GLib.file_test(path, GLib.FileTest.IS_DIR)
	else
		return false
	end
end

---@param file_or_path string | Gio.File
---@return string?
bash.read_file = function(file_or_path)
	if type(file_or_path) == "string" then
		return bash.read_file(Gio.File.new_for_path(file_or_path))
	elseif type(file_or_path) == "userdata" then
		local _, content, _ = file_or_path:load_contents()
		return content
	end
end

---@param file_or_path string | Gio.File
---@return nil
bash.read_file_async = function(file_or_path, callback)
	if type(file_or_path) == "string" then
		return bash.read_file_async(Gio.File.new_for_path(file_or_path), callback)
	elseif type(file_or_path) == "userdata" then
		file_or_path:load_contents_async(nil, function(_, task)
			local _, content, _ = file_or_path:load_contents_finish(task)
			return callback(content)
		end)
	end
end

---@param args any
---@return Gio.FileMonitor
bash.monitor_file = function(args) end
