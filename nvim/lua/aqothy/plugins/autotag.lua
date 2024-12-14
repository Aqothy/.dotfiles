return {
	"windwp/nvim-ts-autotag",
	ft = { "html", "javascriptreact", "typescriptreact" }, -- Load only for these filetypes
	config = function()
		require("nvim-ts-autotag").setup({
			opts = {
				enable_close = false, -- Auto close tags, don't need it if you have emmet LSP
			},
		})
	end,
}
