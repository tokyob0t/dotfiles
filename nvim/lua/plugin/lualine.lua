LocalTheme = require("potato.colors")

local ExcludedFiles = {
	"NvimTree",
	"NvimTree_1",
	"TelescopePrompt",
	"Telescope",
	"[No Name]",
	"[New]",
	"dashboard",
	"aerial",
	"dapui_.",
	"neo%-tree",
}

local navic = require("nvim-navic")

require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "auto",
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		ignore_focus = {},
		always_divide_middle = false,
		globalstatus = true,
		disabled_filetypes = {
			tabline = ExcludedFiles,
			--statusline = ExcludedFiles,
			winbar = ExcludedFiles,
		},
		refresh = {
			statusline = 1000,
			tabline = 1000,
			winbar = 1000,
		},
	},
	sections = {
		lualine_a = {
			{
				"mode",
				fmt = function(str)
					local modes = {
						NORMAL = "RW",
						["O-PENDING"] = "RO",
						VISUAL = "**",
						["V-LINE"] = "**",
						["V-BLOCK"] = "**",
						s = "S",
						S = "SL",
						INSERT = "**",
						ic = "**",
						REPLACE = "RA",
						["V-REPLACE"] = "RV",
						COMMAND = "VIEX",
						READ = "r",
						rm = "r",
						["r?"] = "r",
						["!"] = "!",
						TERMINAL = "",
					}
					if str ~= "" then
						return string.format("%s", modes[str] or str)
					else
						return ""
					end
				end,
			},
		},
		lualine_b = {
			{
				"filename",
				file_status = true,
				newfile_status = true,
				symbols = { modified = "", readonly = "", unnamed = "" },
			},
			{
				"branch",
				fmt = function(str)
					if str ~= "" then
						return string.format("(λ • #%s)", str)
					else
						return ""
					end
				end,
				icon = "",
				color = { gui = "bold,italic" },
			},
		},
		lualine_y = {
			{ "diagnostics" },
			{ "filetype", icons_enabled = false },
			{ "location" },
		},
		lualine_c = {},
		lualine_x = {},
		lualine_z = {},
	},
	inactive_sections = {},
	tabline = {
		lualine_b = {
			{
				"buffers",
				icons_enabled = false,
				show_filename_only = false,
				hide_filename_extension = false,
				show_modified_status = true,
				draw_empty = false,
				mode = 0,
				component_separators = { left = "▎", right = "▎" },
				--section_separators = { left = "▎", right = "▎" },
				symbols = {
					modified = "",
					alternate_file = "",
					directory = "",
				},
				buffers_color = {
					active = { bg = "#111111", fg = LocalTheme.base04 },
					inactive = { bg = LocalTheme.base00, fg = LocalTheme.base02 },
				},
				fmt = function(str)
					if str ~= "[No Name]" then
						return " [" .. str .. "] "
					else
						return
					end
				end,
			},
		},
		lualine_a = {},
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
	winbar = {
		lualine_b = {

			{
				"filetype",
				colored = true,
				icon_only = false,
				icon = { align = "left" },
				color = { bg = "#111111", fg = LocalTheme.base05 },
				padding = { left = 4, right = 0 },
				fmt = function(_)
					local filename = vim.fn.expand("%:t:r")
					if filename ~= "" then
						return " " .. filename
					else
						return ""
					end
				end,
				cond = function()
					return navic.is_available()
				end,
			},
			{
				"separator",
				padding = { left = 1 },
				color = {
					bg = "#111111",
					fg = LocalTheme.base03,
				},
				cond = function()
					return navic.is_available()
				end,
				fmt = function(_)
					local filename = vim.fn.expand("%:t:r")
					if filename ~= "" then
						return ""
					else
						return ""
					end
				end,
			},

			{
				function()
					return navic.get_location()
				end,
				cond = function()
					return navic.is_available()
				end,
				fmt = function(str)
					if str ~= "" then
						return str
					else
						return "..."
					end
				end,
				color = {
					bg = "#111111",
				},
			},
			{
				"dots",
				fmt = function(_)
					return "..."
				end,
				color = {
					bg = "#111111",
					fg = LocalTheme.base03,
				},
				cond = function()
					return vim.fn.expand("%:t:r") ~= "" and not navic.is_available()
				end,
			},
		},
		inactive_winbar = {},
		extensions = {},
	},
})
