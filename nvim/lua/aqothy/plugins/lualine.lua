return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	lazy = vim.fn.argc(-1) == 0,
	config = function()
		local user = require("aqothy.config.user")
		local lualine = require("lualine")

		lualine.setup({
			sections = {
				lualine_a = { "mode" },
				lualine_b = {
					"branch",
					"diff",
					{
						"diagnostics",
						symbols = {
							error = user.signs.error .. " ",
							warn = user.signs.warn .. " ",
							info = user.signs.info .. " ",
							hint = user.signs.hint .. " ",
						},
					},
				},
				lualine_c = {
					{ "filename" },
				},
				lualine_x = {
					{ "encoding" },
					{ "fileformat" },
					{ "filetype" },
					{ "filesize" },
					{
						-- macro recording
						function()
							local recording = vim.fn.reg_recording()
							if recording ~= "" then
								return "Recording @" .. recording
							end
							return ""
						end,
						color = { fg = "#ff9e64" },
					},
				},
				lualine_y = {
					{ "progress", separator = " ", padding = { left = 1, right = 0 } },
					{ "location", padding = { left = 0, right = 1 } },
				},
				lualine_z = {
					function()
						return " " .. os.date("%R")
					end,
				},
			},
			options = {
				theme = "gruvbox-material",
				-- globalstatus = true,
				disabled_filetypes = {
					statusline = {
						"",
						"qf",
						"help",
						-- "oil",
						"lazy",
						"NeogitStatus",
						"NeogitCommitView",
						"noice",
						"snacks_dashboard",
						"snacks_terminal",
						-- "NvimTree",
						"trouble",
						"fugitive",
						"leetcode.nvim",
						"mason",
						"terminal",
						"fzf",
						"netrw",
						"undotree",
						"undotreeDiff",
						"gitsigns-blame",
						"minifiles",
						"DiffviewFiles",
					},
				},
			},
		})
	end,
}
