return {
	"lewis6991/gitsigns.nvim",
	event = { "LazyFile" },
	config = function()
		require("gitsigns").setup({
			signs = {
				add = { text = " ▎" },
				change = { text = " ▎" },
				delete = { text = " " },
				topdelete = { text = " " },
				changedelete = { text = " ▎" },
				untracked = { text = " ┆" },
			},
			signs_staged = {
				add = { text = " ▎" },
				change = { text = " ▎" },
				delete = { text = " " },
				topdelete = { text = " " },
				changedelete = { text = " ▎" },
			},
			attach_to_untracked = true,
			current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
		})
		vim.keymap.set("n", "<leader>gg", "<cmd>Gitsigns blame<CR>")
		Snacks.toggle({
			name = "Git Signs",
			get = function()
				return require("gitsigns.config").config.signcolumn
			end,
			set = function(state)
				require("gitsigns").toggle_signs(state)
			end,
		}):map("<leader>tg")
	end,
}
