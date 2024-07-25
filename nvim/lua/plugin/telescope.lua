require("telescope").setup({
	defaults = {
		file_ignore_patterns = {
			".git/",
			".github/",
			".vscode/",
			"__definitions__/",
			"__git__/",
			"__pycache__/",
			".cargo/",
		},
	},
})
