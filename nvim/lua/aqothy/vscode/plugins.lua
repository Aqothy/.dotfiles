return {
	{
		"kylechui/nvim-surround",
		keys = {
			{ "<C-g>s", mode = "i", desc = "Add surrounding in insert mode" },
			{ "<C-g>S", mode = "i", desc = "Add surrounding on new lines in insert mode" },
			{ "gz", mode = { "n", "v" }, desc = "Surround normal and visual" },
			{ "gzz", mode = "n", desc = "Surround current line" },
			{ "gZ", mode = "n", desc = "Surround on new lines" },
			{ "gZZ", mode = "n", desc = "Surround current line on new lines" },
			{ "Z", mode = "v", desc = "Surround visual selection on new lines" },
			{ "ds", mode = "n", desc = "Delete surrounding" },
			{ "cs", mode = "n", desc = "Change surrounding" },
			{ "cS", mode = "n", desc = "Change surrounding on new lines" },
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
