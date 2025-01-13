return {
	{ "nvim-lua/plenary.nvim", lazy = true },
	{ "MunifTanjim/nui.nvim", lazy = true },
	-- {
	-- 	"nvim-tree/nvim-web-devicons",
	-- 	lazy = true,
	-- 	opts = {},
	-- },
	{
		"alanfortlink/blackjack.nvim",
		cmd = "BlackJackNewGame", -- Lazy load when this command is executed
		keys = { { "<leader>bj", "<cmd>BlackJackNewGame<CR>", desc = "start degen gambling" } },
	},
	{
		"github/copilot.vim",
	},
}
