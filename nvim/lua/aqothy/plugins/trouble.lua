return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		focus = true,
		auto_preview = false,
		warn_no_results = false, -- show a warning when there are no results
		open_no_results = true, -- open the trouble window when there are no results
	},
	cmd = "Trouble",
	keys = {
		{ "<leader>tt", "<cmd>Trouble diagnostics toggle<CR>", desc = "Open trouble workspace diagnostics" },
		{ "<leader>tq", "<cmd>Trouble quickfix toggle<CR>", desc = "Open trouble quickfix list" },
	},
}
