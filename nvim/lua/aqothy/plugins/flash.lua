return {
	"folke/flash.nvim",
	event = "VeryLazy",
	opts = {
		jump = { nohlsearch = true },
		search = {
			exclude = {
				"flash_prompt",
				"qf",
				function(win)
					-- Non-focusable windows.
					return not vim.api.nvim_win_get_config(win).focusable
				end,
			},
		},
	},
	keys = {
		{
			"<C-h>",
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
