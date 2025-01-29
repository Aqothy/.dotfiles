return {
	"akinsho/bufferline.nvim",
	event = "VeryLazy",
	enabled = false,
	keys = {
		{ "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
		{ "<leader>dp", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
		{ "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
		{ "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
		{ "[b", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
		{ "]b", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
		{ "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close other buffers" },
	},
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
