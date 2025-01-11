local folder_icon = require("aqothy.config.user").kinds.Folder

local M = {}

--- Window bar that shows the current file path (in a fancy way).
---@return string
function M.render()
	-- Get the path and expand variables.
	local path = vim.fs.normalize(vim.fn.expand("%:p") --[[@as string]])

	-- Replace slashes by arrows.
	local separator = " %#WinbarSeparator# "

	local prefix, prefix_path = "", ""

	-- If the window gets too narrow, shorten the path and drop the prefix.
	if vim.api.nvim_win_get_width(0) < math.floor(vim.o.columns / 3) then
		path = vim.fn.pathshorten(path)
	else
		-- For some special folders, add a prefix instead of the full path (making
		-- sure to pick the longest prefix).
		---@type table<string, string>
		local special_dirs = {
			CODE = vim.g.projects_dir,
			DOTFILES = vim.g.XDG_CONFIG_HOME,
			HOME = vim.env.HOME,
		}
		for dir_name, dir_path in pairs(special_dirs) do
			if vim.startswith(path, vim.fs.normalize(dir_path)) and #dir_path > #prefix_path then
				prefix, prefix_path = dir_name, dir_path
			end
		end
		if prefix ~= "" then
			path = path:gsub("^" .. prefix_path, "")
			prefix = string.format("%%#WinBarDir#%s %s%s", folder_icon, prefix, separator)
		end
	end

	-- Remove leading slash.
	path = path:gsub("^/", "")

	return table.concat({
		" ",
		prefix,
		table.concat(
			vim.iter(vim.split(path, "/"))
				:map(function(segment)
					return string.format("%%#Winbar#%s", segment)
				end)
				:totable(),
			separator
		),
	})
end

vim.api.nvim_create_autocmd("BufWinEnter", {
	group = vim.api.nvim_create_augroup("aqothy/winbar", { clear = true }),
	desc = "Attach winbar",
	callback = function(args)
		local excluded_filetypes = {
			"",
			"qf",
			"help",
			"lazy",
			"NeogitStatus",
			"NeogitCommitView",
			"noice",
			"snacks_dashboard",
			"snacks_terminal",
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
		}
		local filetype = vim.bo[args.buf].filetype
		if
			not vim.api.nvim_win_get_config(0).zindex -- Not a floating window
			and vim.bo[args.buf].buftype == "" -- Normal buffer
			and vim.api.nvim_buf_get_name(args.buf) ~= "" -- Has a file name
			and not vim.wo[0].diff -- Not in diff mode
			and not vim.tbl_contains(excluded_filetypes, filetype)
		then
			vim.wo.winbar = "%{%v:lua.require'aqothy.config.winbar'.render()%}"
		end
	end,
})

local colors = {
	dark1 = "#3c3836",
	light0_soft = "#f2e5bc",
	bright_green = "#b8bb26",
	neutral_orange = "#d65d0e",
}

-- Set WinBar highlights using Gruvbox Material colors
vim.api.nvim_set_hl(0, "WinBar", { fg = colors.light0_soft, bg = colors.dark1 })
vim.api.nvim_set_hl(0, "WinBarNC", { bg = colors.dark1 })
vim.api.nvim_set_hl(0, "WinBarDir", { fg = colors.neutral_orange, bg = colors.dark1, italic = true })
vim.api.nvim_set_hl(0, "WinBarSeparator", { fg = colors.bright_green, bg = colors.dark1 })

return M
