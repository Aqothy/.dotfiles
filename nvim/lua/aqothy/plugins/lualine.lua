return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
    lazy = false,
    -- event = "VeryLazy",
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
				theme = "gruvbox-material",
				disabled_buftypes = { "quickfix", "prompt", "nofile" },
				disabled_filetypes = {
					statusline = {
						"help",
						"lazy",
						"noice",
						"snacks_dashboard",
						"snacks_terminal",
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
