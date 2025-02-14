local M = {}

local api = vim.api
local bo = vim.bo
local uv = vim.uv or vim.loop

local stl_group = vim.api.nvim_create_augroup("aqline", { clear = true })
local autocmd = vim.api.nvim_create_autocmd

local user = require("aqothy.config.user")
local mini_icons = require("mini.icons")

function M.os_component()
	if not M._os_cache then
		local uname_info = uv.os_uname() or {}
		local sysname = uname_info.sysname or ""
		sysname = (sysname == "Darwin") and "macos" or sysname:lower()
		local icon, icon_hl = mini_icons.get("os", sysname)
		M._os_cache = "%#" .. icon_hl .. "#" .. icon
	end
	return M._os_cache
end

M.MODE_MAP = {
	["n"] = "NORMAL",
	-- OP pending mode is buggy asf
	-- ["no"] = "OP-PENDING",
	-- ["nov"] = "OP-PENDING",
	-- ["noV"] = "OP-PENDING",
	-- ["no\22"] = "OP-PENDING",
	["niI"] = "NORMAL",
	["niR"] = "NORMAL",
	["niV"] = "NORMAL",
	["nt"] = "NORMAL",
	["ntT"] = "NORMAL",
	["v"] = "VISUAL",
	["vs"] = "VISUAL",
	["V"] = "V-LINE",
	["Vs"] = "V-LINE",
	["\22"] = "V-BLOCK",
	["\22s"] = "V-BLOCK",
	["s"] = "SELECT",
	["S"] = "SELECT",
	["\19"] = "SELECT",
	["i"] = "INSERT",
	["ic"] = "INSERT",
	["ix"] = "INSERT",
	["R"] = "REPLACE",
	["Rc"] = "REPLACE",
	["Rx"] = "REPLACE",
	["Rv"] = "V-REPLACE",
	["Rvc"] = "V-REPLACE",
	["Rvx"] = "V-REPLACE",
	["c"] = "COMMAND",
	["cv"] = "EX",
	["ce"] = "EX",
	["r"] = "REPLACE",
	["rm"] = "MORE",
	["r?"] = "CONFIRM",
	["!"] = "SHELL",
	["t"] = "TERMINAL",
}

M.MODE_TO_HIGHLIGHT = {
	NORMAL = "Normal",
	-- ["OP-PENDING"] = "Pending",
	VISUAL = "Visual",
	["V-LINE"] = "Visual",
	["V-BLOCK"] = "Visual",
	SELECT = "Insert",
	INSERT = "Insert",
	COMMAND = "Command",
	EX = "Command",
	TERMINAL = "Command",
}

M.get_mode = function()
	local mode = api.nvim_get_mode().mode
	local mode_str = M.MODE_MAP[mode] or "UNKNOWN"
	local hl = M.MODE_TO_HIGHLIGHT[mode_str] or "Other"

	M.mode_cache = "%#"
		.. "StatuslineModeSeparator"
		.. hl
		.. "#"
		.. ""
		.. "%#"
		.. "StatuslineMode"
		.. hl
		.. "#"
		.. mode_str
		.. "%#"
		.. "StatuslineModeSeparator"
		.. hl
		.. "#"
		.. ""
end

autocmd("ModeChanged", {
	group = stl_group,
	callback = M.get_mode,
})

function M.mode_component()
	if not M.mode_cache then
		M.get_mode()
	end

	return M.mode_cache
end

function M.git_components()
	local git_info = vim.b.gitsigns_status_dict
	if not git_info or git_info.head == "" then
		return "", ""
	end

	-- Head component: Concatenate the symbol and branch name.
	local head = " " .. git_info.head

	local status_parts = {}
	if git_info.added and git_info.added > 0 then
		status_parts[#status_parts + 1] = "%#GitSignsAdd#+" .. git_info.added
	end
	if git_info.changed and git_info.changed > 0 then
		status_parts[#status_parts + 1] = "%#GitSignsChange#~" .. git_info.changed
	end
	if git_info.removed and git_info.removed > 0 then
		status_parts[#status_parts + 1] = "%#GitSignsDelete#-" .. git_info.removed
	end

	local status = (#status_parts > 0) and table.concat(status_parts, " ") or ""
	return head, status
end

M.diagnostic_levels = {
	{ name = "ERROR", sign = user.signs.error, hl = "DiagnosticError" },
	{ name = "WARN", sign = user.signs.warn, hl = "DiagnosticWarn" },
	{ name = "INFO", sign = user.signs.info, hl = "DiagnosticInfo" },
	{ name = "HINT", sign = user.signs.hint, hl = "DiagnosticHint" },
}

M.diagnostic_counts = {}

M.get_diagnostic_count = function(buf_id)
	return vim.diagnostic.count(buf_id)
end

autocmd("DiagnosticChanged", {
	group = stl_group,
	pattern = "*",
	callback = function(data)
		if api.nvim_buf_is_valid(data.buf) then
			M.diagnostic_counts[data.buf] = M.get_diagnostic_count(data.buf)
		else
			M.diagnostic_counts[data.buf] = nil
		end
	end,
	desc = "Track diagnostics",
})

function M.diagnostics_component()
	local buf = api.nvim_get_current_buf()
	local count = M.diagnostic_counts[buf]
	if not count then
		return ""
	end

	local severity = vim.diagnostic.severity
	local parts = {}

	for i = 1, #M.diagnostic_levels do
		local level = M.diagnostic_levels[i]
		local n = count[severity[level.name]] or 0
		if n > 0 then
			parts[#parts + 1] = "%#" .. level.hl .. "#" .. level.sign .. " " .. n
		end
	end

	return (#parts > 0) and table.concat(parts, " ") or ""
end

function M.update_filetype_cache()
	-- For file info but putting it here to take advantage of bufenter and buffilepost
	M.encoding_cache = bo.fileencoding
	M.shiftwidth_cache = bo.shiftwidth

	-- For filetype
	local full_path = api.nvim_buf_get_name(0)
	local icon, icon_hl = mini_icons.get("file", full_path)
	M.filetype_cache = "%#" .. icon_hl .. "#" .. icon .. " %#StatuslineTitle#" .. "%f%m%r"
end

autocmd({ "BufEnter", "BufFilePost" }, {
	group = stl_group,
	callback = M.update_filetype_cache,
})

function M.filetype_component()
	if not M.filetype_cache then
		M.update_filetype_cache()
	end
	return M.filetype_cache
end

-- Update when 'fileencoding' or 'shiftwidth' options change or after buffer enter
autocmd("OptionSet", {
	group = stl_group,
	pattern = { "fileencoding", "shiftwidth" },
	callback = function()
		M.encoding_cache = bo.fileencoding
		M.shiftwidth_cache = bo.shiftwidth
	end,
})

function M.file_info_component()
	if not M.encoding_cache then
		M.encoding_cache = bo.fileencoding
	end

	if not M.shiftwidth_cache then
		M.shiftwidth_cache = bo.shiftwidth
	end
	return "%#StatuslineModeSeparatorOther# " .. M.encoding_cache .. " Tab:" .. M.shiftwidth_cache
end

function M.position_component()
	local line_count = api.nvim_buf_line_count(0)
	return "%#StatuslineItalic#Ln " .. "%#StatuslineTitle#%l" .. "%#StatuslineItalic#/" .. line_count .. " Col %c"
end

function M.render()
	local git_head, git_status = M.git_components()

	local left_components = {}
	local left_candidates = {
		M.os_component(),
		M.mode_component(),
		git_head,
		M.filetype_component(),
		git_status,
	}
	for i = 1, #left_candidates do
		local comp = left_candidates[i]
		if comp and comp ~= "" then
			left_components[#left_components + 1] = comp
		end
	end

	local right_components = {}
	local right_candidates = {
		M.diagnostics_component(),
		M.file_info_component(),
		M.position_component(),
	}
	for i = 1, #right_candidates do
		local comp = right_candidates[i]
		if comp and comp ~= "" then
			right_components[#right_components + 1] = comp
		end
	end

	return " "
		.. table.concat(left_components, "  ")
		.. "%#StatusLine#%="
		.. table.concat(right_components, "  ")
		.. " "
end

vim.opt.statusline = "%!v:lua.require'aqothy.config.statusline'.render()"

return M
