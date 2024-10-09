local Mpris = astal.require("AstalMpris")

local mpris = Mpris.get_default()

return function()
	return Widget.Box({
		bind(mpris, "players"):as(function(players)
			local player = players[1]
			if player then
				return Widget.Box({
					Widget.Label({ label = bind(player, "title") }),
				})
			end
		end),
	})
end
