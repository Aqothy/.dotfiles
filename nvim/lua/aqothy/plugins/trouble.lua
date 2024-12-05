return {
	"folke/trouble.nvim",
	opts = {
		focus = true,
        auto_preview = false,
	},
	cmd = "Trouble",
	keys = {
		{ "<leader>tt", "<cmd>Trouble diagnostics toggle<CR>", desc = "Open trouble workspace diagnostics" },
        { "<leader>tq", "<cmd>Trouble quickfix toggle<CR>", desc = "Open trouble quickfix list" },
	},
}

