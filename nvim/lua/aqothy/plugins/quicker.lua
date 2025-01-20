return {
	"stevearc/quicker.nvim",
	event = "VeryLazy",
	opts = {},
	keys = {
		{
			"<leader>tq",
			function()
				require("quicker").toggle()
			end,
			desc = "Toggle quickfix",
		},
		{
			">",
			function()
				require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
			end,
			desc = "Expand context",
		},
		{
			"<",
			function()
				require("quicker").collapse()
			end,
			desc = "Collapse context",
		},
	},
}
