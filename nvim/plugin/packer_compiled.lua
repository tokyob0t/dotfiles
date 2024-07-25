-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function("has", { "nvim-0.5" }) ~= 1 then
	vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
	return
end

vim.api.nvim_command("packadd packer.nvim")

local no_errors, error_msg = pcall(function()
	_G._packer = _G._packer or {}
	_G._packer.inside_compile = true

	local time
	local profile_info
	local should_profile = false
	if should_profile then
		local hrtime = vim.loop.hrtime
		profile_info = {}
		time = function(chunk, start)
			if start then
				profile_info[chunk] = hrtime()
			else
				profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
			end
		end
	else
		time = function(chunk, start) end
	end

	local function save_profiles(threshold)
		local sorted_times = {}
		for chunk_name, time_taken in pairs(profile_info) do
			sorted_times[#sorted_times + 1] = { chunk_name, time_taken }
		end
		table.sort(sorted_times, function(a, b)
			return a[2] > b[2]
		end)
		local results = {}
		for i, elem in ipairs(sorted_times) do
			if not threshold or threshold and elem[2] > threshold then
				results[i] = elem[1] .. " took " .. elem[2] .. "ms"
			end
		end
		if threshold then
			table.insert(results, "(Only showing plugins that took longer than " .. threshold .. " ms " .. "to load)")
		end

		_G._packer.profile_output = results
	end

	time([[Luarocks path setup]], true)
	local package_path_str =
		"/home/tokyob0t/.cache/nvim/packer_hererocks/2.1.1713773202/share/lua/5.1/?.lua;/home/tokyob0t/.cache/nvim/packer_hererocks/2.1.1713773202/share/lua/5.1/?/init.lua;/home/tokyob0t/.cache/nvim/packer_hererocks/2.1.1713773202/lib/luarocks/rocks-5.1/?.lua;/home/tokyob0t/.cache/nvim/packer_hererocks/2.1.1713773202/lib/luarocks/rocks-5.1/?/init.lua"
	local install_cpath_pattern = "/home/tokyob0t/.cache/nvim/packer_hererocks/2.1.1713773202/lib/lua/5.1/?.so"
	if not string.find(package.path, package_path_str, 1, true) then
		package.path = package.path .. ";" .. package_path_str
	end

	if not string.find(package.cpath, install_cpath_pattern, 1, true) then
		package.cpath = package.cpath .. ";" .. install_cpath_pattern
	end

	time([[Luarocks path setup]], false)
	time([[try_loadstring definition]], true)
	local function try_loadstring(s, component, name)
		local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
		if not success then
			vim.schedule(function()
				vim.api.nvim_notify(
					"packer.nvim: Error running " .. component .. " for " .. name .. ": " .. result,
					vim.log.levels.ERROR,
					{}
				)
			end)
		end
		return result
	end

	time([[try_loadstring definition]], false)
	time([[Defining packer_plugins]], true)
	_G.packer_plugins = {
		LuaSnip = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/LuaSnip",
			url = "https://github.com/L3MON4D3/LuaSnip",
		},
		["cmp-buffer"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/cmp-buffer",
			url = "https://github.com/hrsh7th/cmp-buffer",
		},
		["cmp-cmdline"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/cmp-cmdline",
			url = "https://github.com/hrsh7th/cmp-cmdline",
		},
		["cmp-git"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/cmp-git",
			url = "https://github.com/hrsh7th/cmp-git",
		},
		["cmp-nvim-lsp"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp",
			url = "https://github.com/hrsh7th/cmp-nvim-lsp",
		},
		["cmp-nvim-lua"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/cmp-nvim-lua",
			url = "https://github.com/hrsh7th/cmp-nvim-lua",
		},
		["cmp-path"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/cmp-path",
			url = "https://github.com/hrsh7th/cmp-path",
		},
		cmp_luasnip = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/cmp_luasnip",
			url = "https://github.com/saadparwaiz1/cmp_luasnip",
		},
		["conform.nvim"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/conform.nvim",
			url = "https://github.com/stevearc/conform.nvim",
		},
		["cord.nvim"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/cord.nvim",
			url = "https://github.com/vyfor/cord.nvim",
		},
		["friendly-snippets"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/friendly-snippets",
			url = "https://github.com/rafamadriz/friendly-snippets",
		},
		["gitsigns.nvim"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/gitsigns.nvim",
			url = "https://github.com/lewis6991/gitsigns.nvim",
		},
		["indent-blankline.nvim"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/indent-blankline.nvim",
			url = "https://github.com/lukas-reineke/indent-blankline.nvim",
		},
		["lualine.nvim"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/lualine.nvim",
			url = "https://github.com/nvim-lualine/lualine.nvim",
		},
		["mason-lspconfig.nvim"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/mason-lspconfig.nvim",
			url = "https://github.com/williamboman/mason-lspconfig.nvim",
		},
		["mason.nvim"] = {
			config = {
				"\27LJ\2\n3\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\nmason\frequire\0",
			},
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/mason.nvim",
			url = "https://github.com/williamboman/mason.nvim",
		},
		["mkdir.nvim"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/mkdir.nvim",
			url = "https://github.com/jghauser/mkdir.nvim",
		},
		neoformat = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/neoformat",
			url = "https://github.com/sbdchd/neoformat",
		},
		["noice.nvim"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/noice.nvim",
			url = "https://github.com/folke/noice.nvim",
		},
		["nui.nvim"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/nui.nvim",
			url = "https://github.com/MunifTanjim/nui.nvim",
		},
		["nvim-autopairs"] = {
			config = {
				"\27LJ\2\n<\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\19nvim-autopairs\frequire\0",
			},
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/nvim-autopairs",
			url = "https://github.com/windwp/nvim-autopairs",
		},
		["nvim-cmp"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/nvim-cmp",
			url = "https://github.com/hrsh7th/nvim-cmp",
		},
		["nvim-colorizer.lua"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/nvim-colorizer.lua",
			url = "https://github.com/NvChad/nvim-colorizer.lua",
		},
		["nvim-lspconfig"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
			url = "https://github.com/neovim/nvim-lspconfig",
		},
		["nvim-navic"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/nvim-navic",
			url = "https://github.com/SmiteshP/nvim-navic",
		},
		["nvim-notify"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/nvim-notify",
			url = "https://github.com/rcarriga/nvim-notify",
		},
		["nvim-tree.lua"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/nvim-tree.lua",
			url = "https://github.com/nvim-tree/nvim-tree.lua",
		},
		["nvim-treesitter"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
			url = "https://github.com/nvim-treesitter/nvim-treesitter",
		},
		["nvim-treesitter-context"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/nvim-treesitter-context",
			url = "https://github.com/nvim-treesitter/nvim-treesitter-context",
		},
		["nvim-ufo"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/nvim-ufo",
			url = "https://github.com/kevinhwang91/nvim-ufo",
		},
		["nvim-web-devicons"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
			url = "https://github.com/nvim-tree/nvim-web-devicons",
		},
		["oxocarbon.nvim"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/oxocarbon.nvim",
			url = "https://github.com/nyoom-engineering/oxocarbon.nvim",
		},
		["packer.nvim"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/packer.nvim",
			url = "https://github.com/wbthomason/packer.nvim",
		},
		["plenary.nvim"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/plenary.nvim",
			url = "https://github.com/nvim-lua/plenary.nvim",
		},
		["promise-async"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/promise-async",
			url = "https://github.com/kevinhwang91/promise-async",
		},
		["telescope.nvim"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/telescope.nvim",
			url = "https://github.com/nvim-telescope/telescope.nvim",
		},
		["todo-comments.nvim"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/todo-comments.nvim",
			url = "https://github.com/folke/todo-comments.nvim",
		},
		["trouble.nvim"] = {
			loaded = true,
			path = "/home/tokyob0t/.local/share/nvim/site/pack/packer/start/trouble.nvim",
			url = "https://github.com/folke/trouble.nvim",
		},
	}

	time([[Defining packer_plugins]], false)
	-- Config for: mason.nvim
	time([[Config for mason.nvim]], true)
	try_loadstring(
		"\27LJ\2\n3\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\nmason\frequire\0",
		"config",
		"mason.nvim"
	)
	time([[Config for mason.nvim]], false)
	-- Config for: nvim-autopairs
	time([[Config for nvim-autopairs]], true)
	try_loadstring(
		"\27LJ\2\n<\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\19nvim-autopairs\frequire\0",
		"config",
		"nvim-autopairs"
	)
	time([[Config for nvim-autopairs]], false)

	_G._packer.inside_compile = false
	if _G._packer.needs_bufread == true then
		vim.cmd("doautocmd BufRead")
	end
	_G._packer.needs_bufread = false

	if should_profile then
		save_profiles()
	end
end)

if not no_errors then
	error_msg = error_msg:gsub('"', '\\"')
	vim.api.nvim_command(
		'echohl ErrorMsg | echom "Error in packer_compiled: '
			.. error_msg
			.. '" | echom "Please check your config for correctness" | echohl None'
	)
end
