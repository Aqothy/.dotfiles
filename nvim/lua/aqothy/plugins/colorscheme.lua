return {
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		-- enabled = false,
		config = function()
			require("gruvbox").setup({
				contrast = "soft", -- can be "hard", "soft" or empty string
				transparent_mode = false,
			})

			vim.cmd("colorscheme gruvbox")
		end,
	},
}
