local hydra = {
	"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢤⡀⠀⠰⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⣠⣤⣀⣀⣀⣀⡀⠀⢀⣠⠀⠀⠀⠀⠀⠠⠐⠒⣒⣲⣶⣦⣽⣦⣀⢷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠛⠛⢿⣿⣶⣽⣿⣿⣯⣥⣀⡀⠀⠀⠀⣠⣶⣿⣿⣿⠿⠟⠿⢿⣿⣿⣿⣶⣄⠀⠀⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⠀⠀⠈⠻⠛⠉⠙⠻⣿⣿⣶⣍⠀⠊⢱⣿⣿⣿⡇⠀⠀⠀⠀⠈⣿⣿⣶⣽⣆⠀⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣿⣯⡑⠀⢸⣿⣿⣿⣿⡄⠀⠀⠀⢀⠙⠛⠛⠿⣿⣿⣦⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⢷⠀⠘⣏⠻⣿⣿⣿⣦⣤⣀⣈⣲⣤⣀⣀⡀⠛⠃⠀⠀⠀⠀⠀",
	"⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⠀⠀⠀⠈⠔⠚⣻⣿⣿⣿⣿⣿⣿⣿⣿⣯⣝⣧⣤⣄⣀⠀⠀⠀",
	"⠀⠀⠀⢠⣇⣴⣮⣥⣤⡀⠀⢸⣿⣿⡏⠏⠀⠀⠀⣠⣾⣿⣿⡿⠟⢿⣿⣿⣆⠈⢿⣿⠿⠿⠿⠿⣿⠀⠀⠀",
	"⠀⠀⣠⢿⣿⡿⠿⣿⣿⣷⣅⢸⣿⣿⡇⠀⠀⠀⠔⣹⣿⣿⡏⠀⠀⠈⣿⣿⣿⡀⠀⠠⠄⣀⠀⡆⠀⠀⠀⠀",
	"⠀⢀⣯⣾⡿⠆⠀⢸⣿⣿⣧⠉⣿⣿⣷⡀⠀⠀⢠⣿⣿⣿⣧⡀⠀⢀⣿⣿⣿⠀⠠⣲⣿⣿⣿⣿⣦⡀⠀⠀",
	"⠀⣿⡟⠁⠀⠀⠀⣾⣿⣿⠻⠀⠘⢿⣿⣿⣦⡀⠀⢏⠻⣿⣿⣿⣆⣼⣿⣿⣿⢀⣺⣿⣿⠁⠈⣿⣷⣷⡀⠀",
	"⠀⠀⠀⠀⠀⠀⢸⣿⣿⣇⠁⠀⠀⠀⠙⢿⣿⣿⣷⣮⣄⣹⣿⣿⣿⣿⣿⣿⡿⠀⡿⣿⣿⣄⠀⠀⠈⠹⡿⠀",
	"⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣦⣄⣀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠘⢹⣿⣿⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⠀⠀⠀⠈⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣃⣀⣠⣴⣿⣿⠏⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⠀⠀⠀⠀⠲⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣻⠅⠀⠀⠀⠀⠀⠀⠀⠀",
}

local cmd = vim.cmd

local function button(txt, on_press, shortcut)
	local sc = shortcut

	return {
		type = "button",
		val = txt,
		on_press = on_press,
		opts = {
			position = "center",
			shortcut = sc,
			cursor = 3,
			width = 50,
			align_shortcut = "right",
			hl_shortcut = "Keyword",
		},
	}
end

local sections = {
	header = { type = "text", val = hydra, opts = { position = "center", hl = "Comment" } },

	buttons = {
		type = "group",
		val = {
			button("  Reload last session", function()
				cmd(":Telescope find_files <CR>")
			end, "SPC ."),
			-- button("  Open agenda", function() cmd(":Telescope find_files <CR>") end),
			button("  Recently opened files", function()
				cmd(":Telescope find_files <CR>")
			end, "SPC ,"),
			button("  Open project", function()
				cmd(":Telescope find_files <CR>")
			end, "SPC p"),
			button("  Jump to bookmark", function()
				cmd(":Telescope marks<CR>")
			end, "SPC b"),
			button("  Open private configuration", function()
				cmd(":Telescope keymaps<CR>")
			end, "SPC c"),
			button("  Open documentation", function()
				cmd(":Telescope keymaps<CR>")
			end, "SPC h"),
		},
		opts = { spacing = 1, position = "center" },
	},

	footer = {
		type = "text",
		val = " Abandon All Hope Ye Who Enter Here~ ",
		opts = { position = "center", hl = "Comment" },
	},

	icon = {
		type = "button",
		val = "",
		on_press = function()
			if vim.fn.has("mac") == 1 then
				os.execute("open https://github.com/T0kyoB0y/dotfiles/")
			else
				os.execute("xdg-open https://github.com/T0kyoB0y/dotfiles/")
			end
		end,
		opts = { position = "center", hl = "Decorator" },
	},
}

require("alpha").setup({
	layout = {
		{ type = "padding", val = 4 },
		sections.header,
		{ type = "padding", val = 2 },
		sections.buttons,
		{ type = "padding", val = 2 },
		sections.footer,
		{ type = "padding", val = 1 },
		sections.icon,
	},
})
