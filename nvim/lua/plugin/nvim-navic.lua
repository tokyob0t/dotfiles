local navic = require("nvim-navic")
LocalTheme = require("potato.colors")
require("potato.settings")

navic.setup({
	icons = KindIcons,
	lsp = {
		auto_attach = true,
		preference = nil,
	},
	highlight = true,
	separator = "",
	depth_limit = 6,
	depth_limit_indicator = "..",
	safe_output = true,
	lazy_update_context = false,
	click = true,
	format_text = function(text)
		return " " .. text .. " "
	end,
})

local colors = {
	NavicIconsFile = LocalTheme.base0D,
	NavicIconsModule = LocalTheme.base0B,
	NavicIconsNamespace = LocalTheme.base09,
	NavicIconsPackage = LocalTheme.base0B,
	NavicIconsClass = LocalTheme.base0B,
	NavicIconsConstructor = LocalTheme.base0F,
	NavicIconsMethod = LocalTheme.base0F,
	NavicIconsProperty = LocalTheme.base0E,
	NavicIconsField = LocalTheme.base09,
	NavicIconsEnum = LocalTheme.base08,
	NavicIconsInterface = LocalTheme.base08,
	NavicIconsVariable = LocalTheme.base0E,
	NavicIconsFunction = LocalTheme.base0F,
	NavicIconsConstant = LocalTheme.base0E,
	NavicIconsString = LocalTheme.base0E,
	NavicIconsNumber = LocalTheme.base0F,
	NavicIconsBoolean = LocalTheme.base09,
	NavicIconsArray = LocalTheme.base08,
	NavicIconsObject = LocalTheme.base0E,
	NavicIconsKey = LocalTheme.base09,
	NavicIconsNull = LocalTheme.base08,
	NavicIconsOperator = LocalTheme.base09,
	--
	NavicIconsEnumMember = LocalTheme.base0F,
	NavicIconsStruct = LocalTheme.base0D,
	NavicIconsEvent = LocalTheme.base09,
	NavicIconsTypeParameter = LocalTheme.base0A,
	NavicText = LocalTheme.base05,
	NavicSeparator = LocalTheme.base03,
}

for group, fg_color in pairs(colors) do
	vim.api.nvim_set_hl(0, group, { bg = "#111111", fg = fg_color })
end
