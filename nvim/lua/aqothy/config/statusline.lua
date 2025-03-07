local M = {}

local api = vim.api
local bo = vim.bo
local uv = vim.uv or vim.loop
local fn = vim.fn

local stl_group = vim.api.nvim_create_augroup("aqline", { clear = true })
local autocmd = vim.api.nvim_create_autocmd

local user = require("aqothy.config.user")
local mini_icons = require("mini.icons")

function M.os_component()
	if not M._os_cache then
		local uname_info = uv.os_uname() or {}
		local sysname = uname_info.sysname or ""
		if vim.fn.has("win32") == 1 then
			sysname = "windows"
		else
			sysname = (sysname == "Darwin") and "macos" or sysname:lower()
		end
		local icon, icon_hl = mini_icons.get("os", sysname)
		M._os_cache = "%#" .. icon_hl .. "#" .. icon
	end
	return M._os_cache
end

M.MODE_MAP = {
	["n"] = "NORMAL",
	["niI"] = "NORMAL",
	["niR"] = "NORMAL",
	["niV"] = "NORMAL",
	["nt"] = "NORMAL",
	["ntT"] = "NORMAL",
	["no"] = "OP-PENDING",
	["nov"] = "OP-PENDING",
	["noV"] = "OP-PENDING",
	["no\22"] = "OP-PENDING",
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
	VISUAL = "Visual",
	["OP-PENDING"] = "Pending",
	["V-LINE"] = "Visual",
	["V-BLOCK"] = "Visual",
	["V-REPLACE"] = "Replace",
	REPLACE = "Replace",
	SELECT = "Insert",
	INSERT = "Insert",
	COMMAND = "Command",
	EX = "Command",
	TERMINAL = "Command",
}

function M.update_mode_cache()
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

	-- For op-pending mode to show
	vim.cmd.redrawstatus()
end

-- Only update mode cache when mode changes
autocmd("ModeChanged", {
	group = stl_group,
	callback = vim.schedule_wrap(function()
		M.update_mode_cache()
	end),
})

function M.mode_component()
	if not M.mode_cache then
		M.update_mode_cache()
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
M.diagnostic_str_cache = {}

-- Only get counts when needed instead of on every change
M.get_diagnostic_count = function(buf_id)
	return vim.diagnostic.count(buf_id)
end

-- Clear diagnostic cache when diagnostics change
autocmd("DiagnosticChanged", {
	group = stl_group,
	callback = function(data)
		if api.nvim_buf_is_valid(data.buf) then
			M.diagnostic_counts[data.buf] = M.get_diagnostic_count(data.buf)
			-- Invalidate string cache for this buffer
			M.diagnostic_str_cache[data.buf] = nil
		else
			M.diagnostic_counts[data.buf] = nil
			M.diagnostic_str_cache[data.buf] = nil
		end
	end,
	desc = "Track diagnostics",
})

function M.diagnostics_component()
	if vim.bo.filetype == "lazy" then
		return ""
	end

	local buf = api.nvim_get_current_buf()

	-- Return cached string if available
	if M.diagnostic_str_cache[buf] then
		return M.diagnostic_str_cache[buf]
	end

	local count = M.diagnostic_counts[buf]
	if not count then
		M.diagnostic_str_cache[buf] = ""
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

	local result = (#parts > 0) and table.concat(parts, " ") or ""
	M.diagnostic_str_cache[buf] = result
	return result
end

-- LSP Progress component optimization
---@type table<number, {client: string, kind: string, title: string?}>
M.progress_statuses = {}
M.progress_cache = nil
M.progress_dirty = true

autocmd("LspProgress", {
	group = stl_group,
	desc = "Update LSP progress in statusline",
	pattern = { "begin", "end" },
	callback = function(args)
		if not args.data then
			return
		end
		local client_id = args.data.client_id
		local client = vim.lsp.get_client_by_id(client_id)
		local value = args.data.params.value
		if not client or type(value) ~= "table" then
			return
		end

		-- Mark cache as dirty
		M.progress_dirty = true

		-- Update or create progress entry for this client
		M.progress_statuses[client_id] = {
			client = client.name,
			kind = value.kind,
			title = value.title,
		}

		if value.kind == "end" then
			-- Remove the entry after delay while keeping completion checkmark
			vim.defer_fn(function()
				M.progress_statuses[client_id] = nil
				M.progress_dirty = true
				vim.cmd.redrawstatus()
			end, 3000)
		end
		vim.cmd.redrawstatus()
	end,
})

function M.lsp_progress_component()
	-- Return cached result if not dirty
	if not M.progress_dirty and M.progress_cache then
		return M.progress_cache
	end

	local progress_parts = {}
	for _, status in pairs(M.progress_statuses) do
		if status.title then
			local is_done = status.kind == "end"
			local symbol = is_done and " " or "󱥸 "
			local title = is_done and "" or " %#StatuslineItalic#" .. status.title
			table.insert(
				progress_parts,
				table.concat({
					"%#StatuslineTitle#" .. symbol .. status.client,
					title,
				})
			)
		end
	end

	local result = table.concat(progress_parts, " ")
	M.progress_cache = result
	M.progress_dirty = false
	return result
end

function M.update_file_type()
	M.update_file_info_cache()

	local relative_path = fn.expand("%:.")
	local icon, icon_hl = mini_icons.get("file", relative_path)
	M.file_type_cache = "%#"
		.. icon_hl
		.. "#"
		.. icon
		.. " %#StatuslineTitle#"
		.. (relative_path ~= "" and relative_path or "%t")
		.. "%m%r"
end

-- TermLeave for updating icon after lazygit closes, also accounts for file changes from terminal
autocmd({ "BufEnter", "TermLeave", "WinLeave" }, {
	group = stl_group,
	callback = M.update_file_type,
})

function M.filetype_component()
	if not M.file_type_cache then
		M.update_file_type()
	end
	return M.file_type_cache or ""
end

function M.update_file_info_cache()
	M.file_info_cache = "%#StatuslineModeSeparatorOther# " .. bo.fileencoding .. " Tab:" .. bo.shiftwidth
end

autocmd("OptionSet", {
	group = stl_group,
	pattern = { "fileencoding", "shiftwidth", "filetype" },
	callback = M.update_file_info_cache,
})

function M.file_info_component()
	if not M.file_info_cache then
		M.update_file_info_cache()
	end
	return M.file_info_cache or ""
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
		M.lsp_progress_component(),
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
