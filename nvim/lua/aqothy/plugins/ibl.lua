return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("ibl").setup({
			exclude = {
				buftypes = {
					"terminal",
					"nofile",
				},
				filetypes = {
					"help",
					"lazy",
					"alpha",
					"NvimTree",
					"Trouble",
					"fugitive",
					"leetcode.nvim",
					"mason",
				},
			},
			scope = {
				enabled = false,
			},
		})
	end,
}
