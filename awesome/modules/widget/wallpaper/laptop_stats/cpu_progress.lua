local utils = require("utils.init")

---@type fun(name: string, min: number, max: number): wibox.widget
local f = require("modules.widget.wallpaper.laptop_stats.progressbar")

local cmd = {
	total_ram = { "sh", "-c", [[free --mega | grep Mem: |  awk '{print $2}']] },
	current_ram = { "sh", "-c", [[free --mega | grep "Mem:" |  awk '{print $3}']] },
}

return function()
	local cpu = f("CPU", 0, 100)
	local progressbar = cpu:get_children_by_id("progressbar")[1]
	local label = cpu:get_children_by_id("textbox1")[1]
	local p_label = cpu:get_children_by_id("textbox2")[1]

	label.text = "akbdhgshdbhfsdbfhsj"

	progressbar.value = 10

	return cpu
end
