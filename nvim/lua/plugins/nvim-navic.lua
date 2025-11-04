return {
  "SmiteshP/nvim-navic",
  version = "*",
  lazy = true,
  dependencies = { "neovim/nvim-lspconfig"},
  opts = {
	--icons = KindIcons,
	lsp = { auto_attach = true, preference = nil	},
	highlight = true,
	separator = "",
	depth_limit = 6,
	depth_limit_indicator = "..",
	safe_output = true,
	lazy_update_context = false,
	click = true,
	format_text = function(text)
		return " " .. text .. " "
	end
  }
}

