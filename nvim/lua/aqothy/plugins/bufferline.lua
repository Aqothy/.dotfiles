return {
	"akinsho/bufferline.nvim",
	event = "VeryLazy",
	opts = {
		options = {
			close_command = function(n)
				Snacks.bufdelete(n)
			end,
			right_mouse_command = function(n)
				Snacks.bufdelete(n)
			end,
			separator_style = "slope",
			always_show_bufferline = false,
			diagnostics = "nvim_lsp",
		},
	},
}
