return {
	"nvim-lualine/lualine.nvim",
	config = function()
		local lualine = require("lualine")

		lualine.setup({
			sections = {
				lualine_x = {
					{ "encoding" },
					{ "fileformat" },
					{ "filetype" },
				},
			},
		})
	end,
}
