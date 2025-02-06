return {
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		-- enabled = false,
		config = function()
			local gruvbox = require("gruvbox")

			local colors = gruvbox.palette

			gruvbox.setup({
				contrast = "soft", -- can be "hard", "soft" or empty string
				transparent_mode = false,
				overrides = {
					StatusLine = { fg = colors.light3, bg = colors.dark0_soft, reverse = false }, -- need reverse = false sincd default is true and it messes up the custom statusline
					NormalFloat = { bg = colors.dark0_soft },
					GruvboxBg2 = { fg = colors.gray },
					SignColumn = { bg = colors.dark0_soft },
					Pmenu = { bg = colors.dark0_soft },
				},
			})

			vim.cmd("colorscheme gruvbox")

            -- Make sure it loads after the colorscheme, why? I don't know
			-- Extend the gruvbox hightlight groups
			local mode_colors = {
				Normal = "gray",
				Pending = "neutral_blue",
				Visual = "neutral_orange",
				Insert = "bright_green",
				Command = "neutral_yellow",
				Other = "neutral_purple",
			}

			local groups = {
				StatuslineItalic = { fg = colors.gray, bg = colors.dark0_soft, italic = true },
				StatuslineTitle = { fg = colors.light3, bg = colors.dark0_soft, bold = true },
			}

			-- Add mode-specific groups
			for mode, color in pairs(mode_colors) do
				groups["StatuslineMode" .. mode] = { fg = colors.dark0_soft, bg = colors[color] }
				groups["StatuslineModeSeparator" .. mode] = { fg = colors[color], bg = colors.dark0_soft }
			end

			-- Set all highlight groups
			for group, opts in pairs(groups) do
				vim.api.nvim_set_hl(0, group, opts)
			end
		end,
	},
}
