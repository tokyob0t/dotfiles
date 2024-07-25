local conceal = require("conceal")

conceal.setup({
	["lua"] = {
		enabled = true,
		keywords = {
			["return"] = { highlight = "keyword", conceal = "->" },
			["local"] = { highlight = "keyword", conceal = "~" },
			["if"] = { highlight = "keyword", conceal = "?" },
			["not"] = { highlight = "keyword", conceal = "!" },
			["else"] = { highlight = "keyword", conceal = ":" },
		},
	},
})

conceal.generate_conceals()
