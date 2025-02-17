return {
	"stevearc/quicker.nvim",
	event = "VeryLazy",
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
				require("quicker").expand({ before = 3, after = 3, add_to_existing = true })
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
