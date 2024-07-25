local vim = vim
local api = vim.api
local cmd = vim.cmd
local set = cmd.set
local colorscheme = cmd.colorscheme
local gui = vim.g
local options = vim.opt
local diagnostic = vim.diagnostic
local func = vim.fn

diagnostic.config({
	virtual_lines = false,
	virtual_text = true,
})

gui.loaded_netrw = 1

gui.loaded_netrwPlugin = 1

options.cursorline = true
options.number = true
options.termguicolors = true
options.clipboard = "unnamedplus"
options.fillchars = {
	eob = " ",
	vert = " ",
	horiz = " ",
	diff = "╱",
	foldclose = "",
	foldopen = "",
	fold = " ",
	msgsep = "─",
}

options.listchars = {
	tab = " ──",
	trail = "·",
	nbsp = "␣",
	precedes = "«",
	extends = "»",
}

options.tabstop = 4
options.shiftwidth = 4
options.softtabstop = 4
options.scrolloff = 4
options.grepprg = "rg --vimgrep"
options.grepformat = "%f:%l:%c:%m"
options.signcolumn = "yes:1"
options.updatetime = 250
options.timeoutlen = 400
options.foldcolumn = "1"
options.foldlevel = 99
options.foldlevelstart = 99
options.foldenable = true

colorscheme("oxocarbon")
set("expandtab")
set("infercase")
set("ignorecase")
set("smartcase")
set("gdefault")
set("nowrap")
set("nonumber")
set("list")
set("ignorecase")
set("smartcase")
set("gdefault")
set("undofile")
set("nowritebackup")
set("noswapfile")

cmd("highlight CursorLineNr guibg=#232323")
cmd("highlight MDCodeBlock guibg=#111111")
cmd("set mouse=")
cmd("set conceallevel=1")

api.nvim_command([[
            autocmd BufEnter * if len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) > 1 | set showtabline=2 | else | set showtabline=0 | endif
]])

--api.nvim_set_hl(0, "Normal", { bg = nil })
--api.nvim_set_hl(0, "NormalFloat", { bg = nil })

KindIcons = {
	Method = "  ",
	Function = "  ",
	Constructor = "  ",
	Field = "  ",
	Variable = "  ",
	Class = "  ",
	Interface = "  ",
	Module = "  ",
	Property = "  ",
	Unit = "  ",
	Value = "  ",
	Enum = "  ",
	Keyword = "  ",
	Snippet = "  ",
	Color = "  ",
	File = "  ",
	Reference = "  ",
	Folder = "  ",
	EnumMember = "  ",
	Constant = "  ",
	Struct = "  ",
	Event = "  ",
	Operator = "  ",
	TypeParameter = "  ",
	Namespace = "  ",
	Package = "  ",
	String = "  ",
	Text = "  ",
	Number = "  ",
	Array = "  ",
	Object = "  ",
	Key = "  ",
	Boolean = "  ",
	Null = "  ",
}

DiagnosticSigns = {
	Hint = "󰌶",
	Info = "",
	Warn = "",
	Error = "",
	Other = "",
}

for type, icon in pairs(DiagnosticSigns) do
	local hl = "DiagnosticSign" .. type
	--vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
	func.sign_define(hl, { text = icon, texthl = hl, numhl = nil })
end

vim.filetype.add({
	pattern = { [".*/hypr/.*%.conf"] = "hyprlang" },
})
