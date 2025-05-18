return {
	"otavioschwanck/arrow.nvim",
	keys = { { "'", desc = "Arrow" }, { "m", desc = "Mark Buffer Loc" } },
	opts = {
		separate_by_branch = false,
		buffer_leader_key = "m",
		show_icons = true,
		leader_key = "'", -- Recommended to be a single key
		hide_handbook = false,
		mappings = {
			next_item = "j",
			prev_item = "k",
		},
		window = {
			border = "rounded",
		},
	},
}
