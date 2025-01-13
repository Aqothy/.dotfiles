return {
	"windwp/nvim-ts-autotag",
	ft = {
		"html",
		"javascript",
		"typescript",
		"javascriptreact",
		"typescriptreact",
	},
	config = function()
		require("nvim-ts-autotag").setup({
			opts = {
				enable_close = true,
			},
		})
	end,
}
