return {
	"otavioschwanck/arrow.nvim",
	keys = { { "'" }, { "\\" } },
	opts = {
		separate_by_branch = false,
		per_buffer_config = {
			sort_automatically = true,
			satellite = {
				enable = false,
				overlap = true,
				priority = 1000,
			},
			lines = 7,
			zindex = 20,
		},
		buffer_leader_key = "\\",
		show_icons = true,
		leader_key = "'", -- Recommended to be a single key
		hide_handbook = false,
		window = { -- controls the appearance and position of an arrow window (see nvim_open_win() for all options)
			width = "auto",
			height = "auto",
			row = 10,
			border = "rounded",
		},
	},
}
