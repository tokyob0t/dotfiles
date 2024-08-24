---https://github.com/RMTT/lua-pam/
local user = os.getenv("USER") or os.getenv("LOGNAME")
package.cpath = package.cpath .. ";/home/" .. user .. "/.config/awesome/lib/__git__/pam/build/?.so"

local liblua_pam = require("liblua_pam")

return {
	---@param password string
	---@return boolean
	auth_current_user = function(password)
		return liblua_pam.auth_current_user(password)
	end,
}
