return {
	"akinsho/toggleterm.nvim",
	version = "*",
	config = function()
		vim.keymap.set("n", "<C-t>", "<cmd>ToggleTerm<cr>")
		require("toggleterm").setup({
			start_in_insert = true,
			direction = "float",
			float_opts = {
				border = "curved",
			},
			autochdir = true,
		})
	end,
}
