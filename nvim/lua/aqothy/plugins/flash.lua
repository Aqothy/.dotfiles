return {
	"folke/flash.nvim",
	enabled = false,
	opts = {
		-- Disable enhanced f and t
		modes = {
			char = {
				enabled = false,
			},
		},
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
			"<C-l>",
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
