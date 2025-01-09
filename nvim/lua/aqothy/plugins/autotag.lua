return {
	"windwp/nvim-ts-autotag",
	event = { "LazyFile" },
	config = function()
		require("nvim-ts-autotag").setup({
			opts = {
				enable_close = true,
			},
		})
	end,
}
