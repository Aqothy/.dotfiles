return {
	"folke/lazydev.nvim",
	ft = "lua",
	cmd = "LazyDev",
	enabled = false,
	opts = {
		library = {
			-- { path = "${3rd}/luv/library", words = { "vim%.uv" } },
			{ path = "snacks.nvim", words = { "Snacks" } },
		},
	},
}
