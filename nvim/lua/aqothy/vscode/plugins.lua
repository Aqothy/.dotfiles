return {
	{
		"kylechui/nvim-surround",
		keys = {
			{ "<C-g>s", mode = "i" },
			{ "<C-g>S", mode = "i" },
			{ "gz", mode = { "n", "v" } },
			{ "gzz", mode = "n" },
			{ "gZ", mode = "n" },
			{ "gZZ", mode = "n" },
			{ "Z", mode = "v" },
			{ "ds", mode = "n" },
			{ "cs", mode = "n" },
			{ "cS", mode = "n" },
		},
		opts = {
			keymaps = {
				insert = "<C-g>s",
				insert_line = "<C-g>S",
				normal = "gz",
				normal_cur = "gzz",
				normal_line = "gZ",
				normal_cur_line = "gZZ",
				visual = "gz",
				visual_line = "Z",
				delete = "ds",
				change = "cs",
				change_line = "cS",
			},
		},
	},
	{
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
	},
	{
		"echasnovski/mini.ai",
		event = "VeryLazy",
		opts = function()
			local ai = require("mini.ai")
			return {
				n_lines = 500,
				silent = true,
				custom_textobjects = {
					d = { "%f[%d]%d+" }, -- digits
					t = "", -- Disable custom tag textobjects, built in t is better
					u = ai.gen_spec.function_call(), -- u for "Usage"
					g = function() -- Whole buffer, similar to `gg` and 'G' motion
						local from = { line = 1, col = 1 }
						local to = {
							line = vim.fn.line("$"),
							col = math.max(vim.fn.getline("$"):len(), 1),
						}
						return { from = from, to = to }
					end,
				},
			}
		end,
	},
}
