require("conceal").setup({
	["lua"] = {
		enabled = true,
		keywords = {
			["local"] = {
				enabled = false, -- to disable concealing for "local"
			},
			["return"] = {
				conceal = "R", -- to set the concealing to "R"
			},
			["for"] = {
				highlight = "keyword", -- to set the Highlight group to "@keyword"
			},
		},
	},

	["python"] = {
		enabled = true,
		keywords = {
			["lambda"] = {
				enabled = true,
				conceal = "λ ->",
			},
		},
	},
})

require("conceal").generate_conceals()
