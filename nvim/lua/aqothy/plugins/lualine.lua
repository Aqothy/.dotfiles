return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local lualine = require("lualine")

		lualine.setup({
			sections = {
				lualine_x = {
					{ "encoding" },
					{ "fileformat" },
					{ "filetype" },
					{ "filesize" },
				},
			},
			options = {
				disabled_filetypes = {
					statusline = {
						"help",
						"lazy",
						"alpha",
						"NvimTree",
						"Trouble",
						"text",
						"fugitive",
						"leetcode.nvim",
					},
				},
			},
		})
	end,
}
