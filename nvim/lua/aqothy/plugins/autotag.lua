return {
	"windwp/nvim-ts-autotag",
	ft = {
		"astro",
		"heex",
		"html",
		"html-eex",
		"javascript",
		"javascriptreact",
		"svelte",
		"typescript",
		"typescriptreact",
		"vue",
	},
	config = function()
		require("nvim-ts-autotag").setup({
			opts = {
				enable_close = true,
			},
		})
	end,
}
