local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local navic = require("nvim-navic")

local ExcludedFiles = {
	"NvimTree",
	"NvimTree_1",
	"TelescopePrompt",
	"Telescope",
	"[No Name]",
	"[New]",
	"nil",
	"",
	nil,
}

-- To add custom LSP servers installed with mason, add them to this table
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

local servers = {
	"ast_grep", -- C, C++, Rust, Go, Java, Python, C#, JavaScript, JSX, TypeScript, HTML, CSS, Kotlin, Dart, Lua
	"clangd", -- C/C++
	"bashls", -- Bash
	-- Lua
	"lua_ls",
	"luau_lsp",
	"marksman", -- Markdown
	"jdtls",
	"vimls",
	-- PYTHON
	"pyright",
	"ruff",
	-- CSS/SASS
	"cssls", -- CSS/SCSS
	"somesass_ls", -- SASS/SCSS
	"cssmodules_ls", -- OTHER MODULES FOR CSS
	"css_variables", -- Css Variables
	-- TypeScript/JavaScript
	--"quick_lint_js",
	"tsserver",
	--"biome",
}

local function is_excluded(buffer_name)
	for _, excluded_name in ipairs(ExcludedFiles) do
		if buffer_name:find(excluded_name, 1, true) then
			return true
		end
	end
	return false
end

local function on_attach(client, bufnr)
	local buffer_name = vim.api.nvim_buf_get_name(bufnr)
	if not is_excluded(buffer_name) and client.server_capabilities.documentSymbolProvider then
		navic.attach(client, bufnr)
	end
end

for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup({
		capabilities = capabilities,
		on_attach = on_attach,
	})
end

-- Configura lua-language-server
require("lspconfig").lua_ls.setup({
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				-- Make the server aware of Neovim runtime files,
				-- see also https://github.com/LuaLS/lua-language-server/wiki/Libraries#link-to-workspace .
				-- Lua-dev.nvim also has similar settings for lua ls, https://github.com/folke/neodev.nvim/blob/main/lua/neodev/luals.lua .
				library = {
					--vim.env.VIMRUNTIME,
					--vim.fn.stdpath("config"),
					vim.fn.getcwd(), -- Agrega el directorio actual del workspace
					"/usr/share/lua/5.1/",
				},
				maxPreload = 2000,
				preloadFileSize = 50000,
			},
		},
	},
})
