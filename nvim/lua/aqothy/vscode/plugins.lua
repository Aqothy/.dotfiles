return {
	{
		"echasnovski/mini.surround",
		keys = {
			{ "gz", mode = { "n", "v" } },
			{ "ds" },
			{ "cs" },
		},
		opts = {
			silent = true,
			mappings = {
				add = "gz",
				delete = "ds",
				find = "",
				find_left = "",
				highlight = "",
				replace = "cs",
				update_n_lines = "",
			},
			search_method = "cover_or_next",
		},
	},
	{
		"folke/flash.nvim",
		enabled = false,
		opts = {
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
	},
	{
		"echasnovski/mini.splitjoin",
		keys = {
			{
				"<leader>j",
				desc = "Join/split code block",
				mode = { "n", "x" },
			},
		},
		opts = {
			mappings = {
				toggle = "<leader>j",
				split = "",
				join = "",
			},
		},
	},
}
