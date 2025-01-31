return {
	"folke/persistence.nvim",
	event = "BufReadPre",
	opts = {},
	enabled = false,
	keys = {
		{
			"<leader>rs",
			function()
				require("persistence").load()
			end,
			desc = "Restore Session",
		},
		{
			"<leader>ss",
			function()
				require("persistence").select()
			end,
			desc = "Select Session",
		},
		{
			"<leader>qs",
			function()
				require("persistence").stop()
			end,
			desc = "Don't Save Current Session",
		},
	},
}
