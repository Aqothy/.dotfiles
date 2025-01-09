return {
	"echasnovski/mini.surround",
	keys = {
		{ "gs", mode = { "n", "v" } },
		{ "ds", mode = "n" },
		{ "cs", mode = "n" },
	},
	config = function()
		require("mini.surround").setup({
			mappings = {
				add = "gs",
				delete = "ds",
				find = "",
				find_left = "",
				highlight = "",
				replace = "cs",
				update_n_lines = "",
			},
			search_method = "cover_or_next",
		})
	end,
}
