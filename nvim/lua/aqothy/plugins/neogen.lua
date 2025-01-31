return {
	"danymat/neogen",
	cmd = "Neogen",
	enabled = false,
	keys = {
		{
			"<leader>ng",
			function()
				require("neogen").generate()
			end,
			desc = "Generate Annotations (Neogen)",
		},
	},
	config = function()
		local neogen = require("neogen")

		neogen.setup({
			snippet_engine = "luasnip",
		})
	end,
	-- Uncomment next line if you want to follow only stable versions
	-- version = "*"
}
