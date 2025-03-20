return {
	"folke/flash.nvim",
	-- enabled = false,
	opts = {
		-- Disable enhanced f and t
		modes = {
			char = {
				enabled = false,
			},
		},
		jump = { nohlsearch = true },
	},
	keys = {
		{
			"<C-j>",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump()
			end,
			desc = "Flash",
		},
		{
			"r",
			mode = "o",
			function()
				require("flash").remote()
			end,
			desc = "Remote Flash",
		},
	},
}
