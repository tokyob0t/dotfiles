local utils = require("utils.init")
local Soup = utils.Soup
local GLib = utils.GLib

---@class Response
local Response = {}

---@param  args { url: string, params: table<string, string>, callback: fun(response:Response)}
local get = function(args)
	local session = Soup.Session.new()
	local message = Soup.Message.new("GET", GLib.Uri.parse(args.url, GLib.UriFlags.NONE))

	if args.params then
		for key, value in pairs(args.params) do
		end
	end
end
