return {
	{
		"kylechui/nvim-surround",
		keys = {
			{ "<C-g>s", mode = "i" },
			{ "<C-g>S", mode = "i" },
			{ "gz", mode = { "n", "v" } },
			{ "gzz", mode = "n" },
			{ "gZ", mode = "n" },
			{ "gZZ", mode = "n" },
			{ "Z", mode = "v" },
			{ "ds", mode = "n" },
			{ "cs", mode = "n" },
			{ "cS", mode = "n" },
		},
		opts = {
			keymaps = {
				insert = "<C-g>s",
				insert_line = "<C-g>S",
				normal = "gz",
				normal_cur = "gzz",
				normal_line = "gZ",
				normal_cur_line = "gZZ",
				visual = "gz",
				visual_line = "Z",
				delete = "ds",
				change = "cs",
				change_line = "cS",
			},
		},
	},
}
