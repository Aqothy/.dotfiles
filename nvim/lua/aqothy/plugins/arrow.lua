return {
	"otavioschwanck/arrow.nvim",
	keys = { { "'" }, { "m" } },
	opts = {
		separate_by_branch = true,
		buffer_leader_key = "m",
		show_icons = true,
		leader_key = "'", -- Recommended to be a single key
		hide_handbook = false,
		window = { -- controls the appearance and position of an arrow window (see nvim_open_win() for all options)
			border = "rounded",
		},
	},
}
