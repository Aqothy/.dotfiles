local M = {}

-- Cache frequently used vim functions and APIs
local api = vim.api
local fn = vim.fn
local bo = vim.bo
local diagnostic = vim.diagnostic
local uv = vim.uv or vim.loop

local user = require("aqothy.config.user")

-- Constants
local DIAGNOSTIC_SEVERITY = diagnostic.severity
local SEVERITY_NAMES = {
	[DIAGNOSTIC_SEVERITY.ERROR] = { name = "ERROR", hl = "DiagnosticError" },
	[DIAGNOSTIC_SEVERITY.WARN] = { name = "WARN", hl = "DiagnosticWarn" },
	[DIAGNOSTIC_SEVERITY.INFO] = { name = "INFO", hl = "DiagnosticInfo" },
	[DIAGNOSTIC_SEVERITY.HINT] = { name = "HINT", hl = "DiagnosticHint" },
}

-- Cache mode strings to avoid table recreation
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

-- Cache mode highlight groups
local MODE_HIGHLIGHTS = {
	NORMAL = "Normal",
	PENDING = "Pending",
	VISUAL = "Visual",
	INSERT = "Insert",
	SELECT = "Insert",
	COMMAND = "Command",
	TERMINAL = "Command",
	EX = "Command",
}

-- Utility functions
local function get_mode_hl(mode)
	for pattern, hl in pairs(MODE_HIGHLIGHTS) do
		if mode:find(pattern) then
			return hl
		end
	end
	return "Other"
end

local function format_size(size)
	local suffixes = { "B", "KB", "MB", "GB" }
	local i = 1
	while size > 1024 and i < #suffixes do
		size = size / 1024
		i = i + 1
	end
	return string.format((i == 1) and "%d%s" or "%.1f%s", size, suffixes[i])
end

-- Component functions with caching where appropriate
function M.os_component()
	if not M._os_cache then
		local uname_info = uv.os_uname() or {}
		local sysname = uname_info.sysname or "Unknown"
		local icon = user.os[sysname] or "󱚟"
		M._os_cache = string.format(" %%#%s#%s", sysname, icon)
	end
	return M._os_cache
end

function M.mode_component()
	local current_mode = api.nvim_get_mode().mode
	local mode_str = MODE_MAP[current_mode] or "UNKNOWN"
	local hl = get_mode_hl(mode_str)

	return string.format(
		"%%#StatuslineModeSeparator%s#%%#StatuslineMode%s#%s%%#StatuslineModeSeparator%s#",
		hl,
		hl,
		mode_str,
		hl
	)
end

function M.git_components()
	local git_info = vim.b.gitsigns_status_dict
	if not git_info or git_info.head == "" then
		return "", ""
	end

	-- Head component
	local head = string.format(" %s", git_info.head)

	-- Status component
	local status_parts = {}
	if git_info.added and git_info.added > 0 then
		table.insert(status_parts, "%#GitSignsAdd#+" .. git_info.added)
	end
	if git_info.changed and git_info.changed > 0 then
		table.insert(status_parts, "%#GitSignsChange#~" .. git_info.changed)
	end
	if git_info.removed and git_info.removed > 0 then
		table.insert(status_parts, "%#GitSignsDelete#-" .. git_info.removed)
	end

	return head, #status_parts > 0 and table.concat(status_parts, " ") .. " " or ""
end

function M.lsp_status()
	local lsp_names = vim.tbl_filter(
		function(name)
			return name ~= nil
		end,
		vim.tbl_map(function(client)
			if client.name:lower():match("copilot") then
				return vim.g.copilot_enabled == 1 and user.kinds.Copilot or nil
			end
			return client.name:gsub("_language_server$", "_ls")
		end, vim.lsp.get_clients({ bufnr = 0 }))
	)

	local ft = vim.bo.filetype
	local formatters = ft ~= "" and require("conform").formatters_by_ft[ft] or {}

	local parts = {}
	if #lsp_names > 0 then
		table.insert(parts, table.concat(lsp_names, ", "))
	end
	if #formatters > 0 then
		table.insert(parts, table.concat(formatters, ", "))
	end

	return #parts > 0 and string.format("%%#StatuslineLsp#%s", table.concat(parts, ", ")) or ""
end

-- Cached diagnostics component
local last_diagnostic_component = ""

function M.diagnostics_component()
	if bo.filetype == "lazy" or api.nvim_get_mode().mode:match("^i") then
		return last_diagnostic_component
	end

	local diagnostics = diagnostic.get(0)
	if #diagnostics == 0 then
		last_diagnostic_component = ""
		return ""
	end

	local counts = { 0, 0, 0, 0 }
	for _, diag in ipairs(diagnostics) do
		counts[diag.severity] = counts[diag.severity] + 1
	end

	local parts = {}
	for severity, count in ipairs(counts) do
		if count > 0 then
			local severity_info = SEVERITY_NAMES[severity]
			table.insert(
				parts,
				string.format("%%#%s#%s %d", severity_info.hl, user.signs[severity_info.name:lower()], count)
			)
		end
	end

	last_diagnostic_component = table.concat(parts, " ")
	return last_diagnostic_component
end

function M.filetype_component()
	local ft = bo.filetype
	if ft == "" then
		ft = "[No Name]"
	end

	local devicons = require("nvim-web-devicons")
	local buf_name = api.nvim_buf_get_name(0)
	local name = fn.fnamemodify(buf_name, ":t")
	local ext = fn.fnamemodify(buf_name, ":e")

	local icon, icon_hl = devicons.get_icon(name, ext)
	if not icon then
		icon, icon_hl = devicons.get_icon_by_filetype(ft, { default = true })
	end

	return string.format("%%#%s#%s %%#StatuslineTitle#%s", icon_hl, icon, ft)
end

function M.file_info_component()
	local encoding = bo.fileencoding
	local shiftwidth = bo.shiftwidth
	local file_path = api.nvim_buf_get_name(0)

	if file_path == "" and encoding == "" and shiftwidth == 0 then
		return ""
	end

	local size_str = ""
	if file_path ~= "" then
		local file_size = fn.getfsize(file_path)
		if file_size > 0 then
			size_str = format_size(file_size)
		end
	end

	return string.format("%%#StatuslineModeSeparatorOther# %s  Tab:%d  %s", encoding, shiftwidth, size_str)
end

function M.position_component()
	return string.format(
		"%%#StatuslineItalic#Ln: %%#StatuslineTitle#%d%%#StatuslineItalic#/%d Col: %d",
		fn.line("."),
		api.nvim_buf_line_count(0),
		fn.virtcol(".")
	)
end

function M.macro_recording_component()
	local reg = fn.reg_recording()
	return reg ~= "" and string.format("%%#StatuslineMacro#Recording @%s", reg) or ""
end

-- Efficient component concatenation
local function concat_components(components)
	return table.concat(components, "  ")
end

-- Main render function
function M.render()
	local git_head, git_status = M.git_components()

	local left_components = vim.tbl_filter(function(component)
		return #component > 0
	end, {
		M.os_component(),
		M.mode_component(),
		git_head,
		M.lsp_status(),
		git_status,
	})

	local right_components = vim.tbl_filter(function(component)
		return #component > 0
	end, {
		M.macro_recording_component(),
		M.diagnostics_component(),
		M.filetype_component(),
		M.file_info_component(),
		M.position_component(),
	})

	return table.concat({
		concat_components(left_components),
		"%#Statusline#%=",
		concat_components(right_components),
		" ",
	})
end

-- Set up the statusline
vim.opt.statusline = "%!v:lua.require'aqothy.config.statusline'.render()"

return M
