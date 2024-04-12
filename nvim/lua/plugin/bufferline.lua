require("bufferline").setup({
	options = {

		indicator = {
			style = "none",
			icon = "│",
		},

		separator_style = { "│", "│" },
		show_duplicate_prefix = false, -- whether to show duplicate buffer prefix
		always_show_bufferline = false,
		buffer_close_icon = "✗",
		close_icon = "✗",
		modified_icon = "",
		left_trunc_marker = "«",
		right_trunc_marker = "»",
		show_buffer_icons = false,
		numbers = "none",
		sort_by = "directory",
		max_name_length = 25,
		style_preset = {
			require("bufferline").style_preset.no_italic,
			require("bufferline").style_preset.no_bold,
		},
		name_formatter = function(buf)
			local name = buf.name
			local path = buf.path
			if name == "[No Name]" then
				return name
			else
				local filename = path:match("^.+/(.+)$") or path
				local words = {}
				local truncated = ""

				for word in path:gmatch("[^/]+") do
					table.insert(words, word)
				end

				local numWords = #words
				local counter = 1

				for i = numWords, 1, -1 do
					if counter <= 3 then
						truncated = words[i]:sub(1, 1) .. "/" .. truncated
						counter = counter + 1
					else
						break
					end
				end
				truncated = string.sub(truncated, 1, -3)

				if #words > 7 then
					return string.format("[.../%s%s]", truncated, filename)
				else
					return string.format("[../%s%s]", truncated, filename)
				end
			end
		end,
		hover = {
			enabled = true,
			delay = 250,
			reveal = {
				"close",
			},
		},
		offsets = {
			{
				filetype = "NvimTree",
				text = "File Explorer",
				highlight = "Function",
				text_align = "center",
				separator = "",
			},
		},
	},
	highlights = {
		fill = {
			bg = "#111111",
		},
		background = {
			fg = LocalTheme.base02,
			bg = "#111111",
		},
		tab = {
			fg = LocalTheme.base02,
			bg = LocalTheme.base01,
		},
		tab_selected = {
			fg = LocalTheme.base03,
			bg = "#111111",
		},
		tab_close = {
			fg = LocalTheme.base01,
		},
		modified = {
			fg = LocalTheme.base0A,
			bg = "#111111",
		},
		modified_selected = {
			fg = LocalTheme.base0C,
			bg = LocalTheme.base01,
		},
		duplicate = {
			italic = true,
		},
		duplicate_selected = {
			italic = true,
		},
		indicator_selected = {
			fg = "#f24f72",
			bg = nil,
		},
	},
})
