require("conform").setup({
	formatters_by_ft = {
		c = { { "ast-grep", "clang-format" } },
		["c++"] = { { "ast-grep", "clang-format" } },
		rust = { "ast-grep" },
		go = { "ast-grep" },
		java = { { "clang-format", "google-java-format", "ast-grep" } },
		python = { "black", "isort" },
		["c#"] = { { "ast-grep", "clang-format" } },
		javascript = { { "ast-grep", "clang-format", "prettier", "prettierd" } },
		jsx = { { "ast-grep", "clang-format", "prettier", "prettierd", "biome" } },
		typescript = { { "ast-grep", "clang-format", "prettier", "prettierd", "ts-standard", "biome" } },
		html = { { "ast-grep", "clang-format", "prettier", "prettierd" } },
		css = { { "ast-grep", "clang-format", "prettier", "prettierd", "beautysh", "css-variables-language-server" } },
		kotlin = { "ast-grep" },
		dart = { "ast-grep" },
		lua = { { "stylua", "lua-language-server", "luaformatter" } },
		markdown = { { "alex", "prettier", "prettierd" } },
	},

	format_on_save = {
		lsp_fallback = true,
		timeout_ms = 500,
	},
})
