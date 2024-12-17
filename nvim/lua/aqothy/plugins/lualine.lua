return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local lualine = require("lualine")

		lualine.setup({
			sections = {
				lualine_c = {
					{ "filename", path = 1 },
				},
				lualine_x = {
					{ "encoding" },
					{ "fileformat" },
					{ "filetype" },
					{ "filesize" },
				},
			},
			options = {
				theme = "auto",
				disabled_buftypes = { "quickfix", "prompt", "nofile" },
				disabled_filetypes = {
					statusline = {
						"Telescope",
						"help",
						"lazy",
						"snacks_dashboard",
						"NvimTree",
						"trouble",
						"fugitive",
						"leetcode.nvim",
						"mason",
						"terminal",
					},
				},
			},
		})
	end,
}
