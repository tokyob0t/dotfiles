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
}

local servers = {
	"clangd", -- C/C++
	"pyright", -- Python
	"tsserver", -- TypeScript/JavaScript
	"cssls", -- CSS/SCSS
	"bashls", -- Bash
	"lua_ls", -- Lua
	"rust_analyzer", -- Rust
	"svelte", -- Svelte
	--"perlnavigator",
	"perlpls", -- Perl
	"marksman", -- Markdown
}

local function isExcluded(buffer_name)
	for _, excluded_name in ipairs(ExcludedFiles) do
		if buffer_name:find(excluded_name, 1, true) then
			return true
		end
	end
	return false
end

local on_attach = function(client, bufnr)
	local buffer_name = vim.api.nvim_buf_get_name(bufnr)
	if not isExcluded(buffer_name) and client.server_capabilities.documentSymbolProvider then
		navic.attach(client, bufnr)
	end
end

for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup({
		capabilities = capabilities,
		on_attach = on_attach,
	})
end
