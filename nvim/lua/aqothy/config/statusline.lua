local M = {}

-- Cache frequently used vim functions and APIs
local api = vim.api
local fn = vim.fn
local bo = vim.bo
local uv = vim.uv or vim.loop

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

local MODE_MAP = {
	["n"] = "NORMAL",
	["no"] = "OP-PENDING",
	["nov"] = "OP-PENDING",
	["noV"] = "OP-PENDING",
	["no\22"] = "OP-PENDING",
	["niI"] = "NORMAL",
	["niR"] = "NORMAL",
	["niV"] = "NORMAL",
	["nt"] = "NORMAL",
	["ntT"] = "NORMAL",
	["v"] = "VISUAL",
	["vs"] = "VISUAL",
	["V"] = "VISUAL",
	["Vs"] = "VISUAL",
	["\22"] = "VISUAL",
	["\22s"] = "VISUAL",
	["s"] = "SELECT",
	["S"] = "SELECT",
	["\19"] = "SELECT",
	["i"] = "INSERT",
	["ic"] = "INSERT",
	["ix"] = "INSERT",
	["R"] = "REPLACE",
	["Rc"] = "REPLACE",
	["Rx"] = "REPLACE",
	["Rv"] = "VIRT REPLACE",
	["Rvc"] = "VIRT REPLACE",
	["Rvx"] = "VIRT REPLACE",
	["c"] = "COMMAND",
	["cv"] = "VIM EX",
	["ce"] = "EX",
	["r"] = "PROMPT",
	["rm"] = "MORE",
	["r?"] = "CONFIRM",
	["!"] = "SHELL",
	["t"] = "TERMINAL",
}

-- Precomputed mapping from mode strings to highlight groups.
local MODE_TO_HIGHLIGHT = {
	NORMAL = "Normal",
	["OP-PENDING"] = "Pending",
	VISUAL = "Visual",
	SELECT = "Insert",
	INSERT = "Insert",
	COMMAND = "Command",
	EX = "Command",
	TERMINAL = "Command",
}

local mode_group = api.nvim_create_augroup("ModeUpdates", {})

-- Update the statusline on mode change, need this for op-pending to show
api.nvim_create_autocmd("ModeChanged", {
	pattern = "*",
	callback = function()
		vim.cmd("redrawstatus")
	end,
	group = mode_group,
})

function M.mode_component()
	local mode = api.nvim_get_mode().mode
	local mode_str = MODE_MAP[mode] or "UNKNOWN"
	local hl = MODE_TO_HIGHLIGHT[mode_str] or "Other"

	return "%#"
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

local diag_group = api.nvim_create_augroup("Track_Diag", { clear = true })

M.get_diagnostic_count = function(buf_id)
	return vim.diagnostic.count(buf_id)
end

api.nvim_create_autocmd("DiagnosticChanged", {
	group = diag_group,
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

	-- Iterate through diagnostic levels
	for i = 1, #M.diagnostic_levels do
		local level = M.diagnostic_levels[i]
		local n = count[severity[level.name]] or 0
		if n > 0 then
			-- Build the statusline segment by concatenation.
			parts[#parts + 1] = "%#" .. level.hl .. "#" .. level.sign .. " " .. n
		end
	end

	return (#parts > 0) and table.concat(parts, " ") or ""
end

local function update_filetype_cache()
	local full_path = api.nvim_buf_get_name(0)
	local icon, icon_hl = mini_icons.get("file", full_path)
	M.filetype_cache = "%#" .. icon_hl .. "#" .. icon .. " %#StatuslineTitle#" .. "%f%m%r"
end

local filetype_group = api.nvim_create_augroup("FileTypeCache", { clear = true })

api.nvim_create_autocmd({ "BufEnter", "BufFilePost" }, {
	group = filetype_group,
	callback = update_filetype_cache,
})

function M.filetype_component()
	if not M.filetype_cache then
		update_filetype_cache()
	end
	return M.filetype_cache
end

local function format_size()
	local size = math.max(fn.line2byte(fn.line("$") + 1) - 1, 0)
	if size < 1024 then
		return size .. "B"
	elseif size < 1048576 then
		return ("%.2fKB"):format(size / 1024)
	else
		return ("%.2fMB"):format(size / 1048576)
	end
end

local function update_file_info_cache()
	local encoding = bo.fileencoding
	local shiftwidth = bo.shiftwidth
	local size_str = format_size()
	M.file_info_cache = "%#StatuslineModeSeparatorOther# " .. encoding .. " Tab:" .. shiftwidth .. " " .. size_str
end

local file_info_group = api.nvim_create_augroup("FileInfoCache", { clear = true })

-- Update on buffer enter and after saving.
api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
	group = file_info_group,
	callback = function()
		update_file_info_cache()
	end,
})

-- Update when 'fileencoding' or 'shiftwidth' options change.
api.nvim_create_autocmd("OptionSet", {
	group = file_info_group,
	pattern = { "fileencoding", "shiftwidth" },
	callback = function()
		update_file_info_cache()
	end,
})

function M.file_info_component()
	return M.file_info_cache or ""
end

function M.position_component()
	local line = fn.line(".")
	local line_count = api.nvim_buf_line_count(0)
	local col = fn.virtcol(".")
	return "%#StatuslineItalic#Ln "
		.. "%#StatuslineTitle#"
		.. line
		.. "%#StatuslineItalic#/"
		.. line_count
		.. " Col "
		.. col
end

-- Main render function
function M.render()
	local git_head, git_status = M.git_components() -- assuming this exists

	-- Build left/right components using a simple loop to filter out empty strings.
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

	-- Concatenate all parts. "%=" creates the separation between left and right.
	return " "
		.. table.concat(left_components, "  ")
		.. "%#StatusLine#%="
		.. table.concat(right_components, "  ")
		.. " "
end

-- Set up the statusline
vim.opt.statusline = "%!v:lua.require'aqothy.config.statusline'.render()"

return M
