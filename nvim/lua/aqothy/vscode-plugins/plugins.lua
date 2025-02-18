return {
	{
		"echasnovski/mini.surround",
		keys = {
			{ "gz", mode = { "n", "v" } },
			{ "ds" },
			{ "cs" },
		},
		opts = {
			silent = true,
			mappings = {
				add = "gz",
				delete = "ds",
				find = "",
				find_left = "",
				highlight = "",
				replace = "cs",
				update_n_lines = "",
			},
			search_method = "cover_or_next",
		},
	},
}
