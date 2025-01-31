return {
	{ "nvim-lua/plenary.nvim", lazy = true },
	-- { "MunifTanjim/nui.nvim", lazy = true },
	-- {
	-- 	"alanfortlink/blackjack.nvim",
	-- 	cmd = "BlackJackNewGame", -- Lazy load when this command is executed
	-- 	keys = { { "<leader>bj", "<cmd>BlackJackNewGame<CR>", desc = "start degen gambling" } },
	-- },
	{
		"github/copilot.vim",
		init = function()
			vim.g.copilot_enabled = 1
			vim.g.copilot_no_tab_map = true

			vim.api.nvim_set_keymap(
				"i",
				"<C-enter>",
				"copilot#Accept()",
				{ expr = true, silent = true, noremap = false }
			)
			vim.keymap.set("i", "<M-]>", "copilot#Next()", { expr = true, silent = true })
			vim.keymap.set("i", "<M-[>", "copilot#Previous()", { expr = true, silent = true })
		end,
	},
}
