return {
	"folke/flash.nvim",
	opts = {
		-- Disable enhanced f and t
		modes = {
			char = {
				enabled = false,
			},
		},
		label = {
			uppercase = false,
		},
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
			"<C-s>",
			mode = { "n", "x", "o" },
			function()
				require("flash").treesitter()
			end,
			desc = "Flash Treesitter",
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
