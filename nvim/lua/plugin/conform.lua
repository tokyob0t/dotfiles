require("conform").setup({
	formatters_by_ft = {
		c = { { "clang-format" } },
		["c++"] = { { "clang-format" } },
		java = { { "google-java-format" } },
		python = { { "blue", "isort" } },
		javascript = { { "biome", "ts-standard" } },
		typescript = { { "biome", "ts-standard" } },
		json = { { "biome" } },
		lua = { { "stylua", "luaformatter" } },
		markdown = { { "alex" } },
		xml = { { "xmlformatter" } },
		bash = { { "beautysh", "shfmt" } },
		["*"] = { { "ast-grep", "prettier", "prettierd" } },
	},

	format_on_save = {
		lsp_fallback = true,
		timeout_ms = 750,
	},
})
