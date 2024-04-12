require("ibl").setup({

	indent = {
		char = "│", -- Carácter de indentación
		tab_char = "", -- Carácter para las tabulaciones
		highlight = { "Function", "Label", "CursorColumn", "Whitespace" },
	},
	scope = {
		enabled = false, -- Habilitar o deshabilitar el resaltado de alcance
		show_start = false, -- Mostrar el inicio de la función/estructura
	},
})
