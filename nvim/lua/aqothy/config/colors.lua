local colors = require("gruvbox").palette

-- Create mode-specific highlights
local mode_colors = {
	Normal = "gray",
	Pending = "neutral_blue",
	Visual = "neutral_orange",
	Insert = "bright_green",
	Command = "neutral_yellow",
	Other = "neutral_purple",
}

local groups = {
	Statusline = { fg = colors.light3, bg = colors.dark0_soft },
	StatuslineItalic = { fg = colors.gray, bg = colors.dark0_soft, italic = true },
	StatuslineTitle = { fg = colors.light3, bg = colors.dark0_soft, bold = true },
	StatuslineLsp = { fg = colors.light3, bg = colors.dark0_soft },
	StatuslineMacro = { fg = colors.bright_orange, bg = colors.dark0_soft },
	Darwin = { fg = colors.light3, bg = colors.dark0_soft, bold = true },
	Windows = { fg = colors.neutral_blue, bg = colors.dark0_soft, bold = true },
	Linux = { fg = colors.faded_blue, bg = colors.dark0_soft, bold = true },
	Unknown = { fg = colors.faded_purple, bg = colors.dark0_soft, bold = true },
	WinBar = { fg = colors.light3, bg = colors.dark0_soft },
	WinBarNC = { bg = colors.dark0_soft },
	WinBarDir = { fg = colors.neutral_orange, bg = colors.dark0_soft, italic = true },
	WinBarSeparator = { fg = colors.neutral_aqua, bg = colors.dark0_soft },
}

-- Add mode-specific groups
for mode, color in pairs(mode_colors) do
	groups["StatuslineMode" .. mode] = { fg = colors.dark0_soft, bg = colors[color] }
	groups["StatuslineModeSeparator" .. mode] = { fg = colors[color], bg = colors.dark0_soft }
end

-- Add diagnostic highlight groups
local diagnostic_colors = {
	Error = "bright_red",
	Warn = "bright_yellow",
	Info = "bright_blue",
	Hint = "bright_aqua",
}

for name, color in pairs(diagnostic_colors) do
	groups["Diagnostic" .. name] = {
		fg = colors[color],
		bg = colors.dark0_soft,
	}
end

-- Set all highlight groups
for group, opts in pairs(groups) do
	vim.api.nvim_set_hl(0, group, opts)
end
