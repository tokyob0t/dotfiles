require("plugin.lualine")
require("plugin.noice")
require("plugin.indent-blankline")
require("plugin.nvim-cmp")
require("plugin.nvim-tree")
require("plugin.nvim-treesitter")
require("plugin.nvim-colorizer")
require("plugin.nvim-lspconfig")
--require("plugin.alpha-nvim")
--require("plugin.conceal")
--require("plugin.bufferline")
require("plugin.trouble")
require("plugin.conform")
require("plugin.gitsigns")
require("plugin.telescope")
--require("plugin.neorg")

require("plugin.presence")
require("plugin.nvim-navic")
require("plugin.nvim-ufo")

local vim = vim

vim.cmd([[packadd packer.nvim]])

require("packer").startup(function(use)
	-- Packer itself
	use({ "wbthomason/packer.nvim" })

	-- Theme
	use({ "nyoom-engineering/oxocarbon.nvim" })

	-- Utils/Useless
	use({ "andweeb/presence.nvim" })
	use({ "NvChad/nvim-colorizer.lua" })
	use({ "jghauser/mkdir.nvim" })
	use({ "SmiteshP/nvim-navic", requires = "neovim/nvim-lspconfig" })
	use({ "kevinhwang91/nvim-ufo", requires = "kevinhwang91/promise-async" })
	use({
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup()
		end,
	})
	--use({ "Jxstxs/conceal.nvim", requires = "nvim-treesitter/nvim-treesitter" })

	-- UI stuff

	use({ "lewis6991/gitsigns.nvim" })
	use({ "nvim-lualine/lualine.nvim" })
	use({ "lukas-reineke/indent-blankline.nvim" })
	--use({ "akinsho/bufferline.nvim", requires = "nvim-tree/nvim-web-devicons" })
	use({ "nvim-telescope/telescope.nvim", tag = "0.1.5", requires = { "nvim-lua/plenary.nvim" } })
	use({
		"folke/trouble.nvim",
		requires = {
			"folke/noice.nvim",
			"folke/todo-comments.nvim",
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
	})
	-- Autocompletion/Formatting
	-- Markdown stuff
	use({ "sbdchd/neoformat" })
	use({ "stevearc/conform.nvim" })
	use({ "nvim-tree/nvim-tree.lua", requires = { "nvim-tree/nvim-web-devicons" } })
	use({ "nvim-treesitter/nvim-treesitter", requires = { "nvim-treesitter/nvim-treesitter-context" } })
	use({
		"williamboman/mason.nvim",
		requires = { "williamboman/mason-lspconfig.nvim" },
		config = function()
			require("mason").setup()
		end,
	})
	use({
		"hrsh7th/nvim-cmp",
		requires = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-git",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-nvim-lsp",
			"neovim/nvim-lspconfig",
			"windwp/nvim-autopairs",
			-- Snippets
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		},
	})
end)
