return {
	"folke/trouble.nvim",
	opts = {
		focus = true,
	},
	cmd = "Trouble",
	keys = {
		{ "<leader>tt", "<cmd>Trouble diagnostics toggle<CR>", desc = "Open trouble workspace diagnostics" },
	},
}

