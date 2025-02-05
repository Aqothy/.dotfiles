return {
	"toppair/peek.nvim",
	build = "deno task --quiet build:fast",
    enabled = false,
	keys = {
		{
			"<leader>mp",
			function()
				require("peek").open()
			end,
			desc = "Peek open",
		},
	},
	opts = {},
}
