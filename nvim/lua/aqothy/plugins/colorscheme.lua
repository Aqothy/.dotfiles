return {
	{
		"ellisonleao/gruvbox.nvim",
		-- enabled = false,
		priority = 500,
		config = function()
			local gruvbox = require("gruvbox")

			local colors = gruvbox.palette

			local is_dark = vim.o.background == "dark"
			local overrides
			local groups

			if is_dark then
				overrides = {
					StatusLine = { fg = colors.light3, bg = colors.dark0_soft, reverse = false }, -- need reverse = false since default is true and it messes up the custom statusline
					NormalFloat = { bg = colors.dark0_soft },
					GruvboxBg2 = { fg = colors.gray },
					SignColumn = { bg = colors.dark0_soft },
					Pmenu = { bg = colors.dark0_soft },
					TreesitterContextBottom = { underline = true, sp = colors.dark3 },
					LspReferenceText = { link = "Visual" },
					LspReferenceRead = { link = "Visual" },
					LspReferenceWrite = { link = "Visual" },
				}

				groups = {
					StatuslineItalic = { fg = colors.gray, bg = colors.dark0_soft, italic = true },
					StatuslineTitle = { fg = colors.light3, bg = colors.dark0_soft, bold = true },
				}
			else
				overrides = {
					StatusLine = { fg = colors.gray, bg = colors.light0_soft, reverse = false },
					NormalFloat = { bg = colors.light0_soft },
					SignColumn = { bg = colors.light0_soft },
					GruvboxBg2 = { fg = colors.gray },
					Pmenu = { bg = colors.light0_soft },
					TreesitterContextBottom = { underline = true, sp = colors.light3 },
					LspReferenceText = { bg = "#CAC2A6" },
					LspReferenceRead = { bg = "#CAC2A6" },
					LspReferenceWrite = { bg = "#CAC2A6" },
				}

				groups = {
					StatuslineItalic = { fg = colors.dark0_soft, bg = colors.light0_soft, italic = true },
					StatuslineTitle = { fg = colors.gray, bg = colors.light0_soft, bold = true },
				}
			end

			gruvbox.setup({
				contrast = "soft", -- can be "hard", "soft" or empty string
				transparent_mode = false,
				overrides = overrides,
			})

			vim.cmd("colorscheme gruvbox")

			-- Extend the gruvbox hightlight groups
			local mode_colors = {
				Normal = "gray",
				Pending = "neutral_blue",
				Replace = "neutral_aqua",
				Visual = "neutral_orange",
				Insert = "bright_green",
				Command = "neutral_yellow",
				Other = "neutral_purple",
			}

			-- Add mode-specific groups
			for mode, color in pairs(mode_colors) do
				groups["StatuslineMode" .. mode] = { fg = colors.dark0_soft, bg = colors[color] }
				groups["StatuslineModeSeparator" .. mode] =
					{ fg = colors[color], bg = is_dark and colors.dark0_soft or colors.light0_soft }
			end

			-- Set all highlight groups
			for group, opts in pairs(groups) do
				vim.api.nvim_set_hl(0, group, opts)
			end
		end,
	},
}
