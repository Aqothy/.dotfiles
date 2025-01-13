-- Done with a lot of ai prompt, research and mald, coding style varies LOL, pre sure its really optimized tho...

local M = {}

-- -- Cache for created highlight groups
-- ---@type table<string, boolean>
-- local statusline_hls = {}

local user = require("aqothy.config.user")

local function augroup(name)
	return vim.api.nvim_create_augroup("aqothy" .. name, { clear = true })
end

---@param hl string
---@return string
-- function M.get_or_create_hl(hl)
-- 	local hl_name = "Statusline" .. hl
--
-- 	if not statusline_hls[hl] then
-- 		-- If not in the cache, create the highlight group using the icon's foreground color
-- 		-- and the statusline's background color.
-- 		local bg_hl = vim.api.nvim_get_hl(0, { name = "Statusline" })
-- 		local fg_hl = vim.api.nvim_get_hl(0, { name = hl })
--
-- 		-- Resolve the link if it exists, just for mini icons holy finally solved it
-- 		if fg_hl.link then
-- 			-- Fetch the linked group's highlight info
-- 			fg_hl = vim.api.nvim_get_hl(0, { name = fg_hl.link })
-- 		end
--
-- 		vim.api.nvim_set_hl(0, hl_name, { bg = ("#%06x"):format(bg_hl.bg), fg = ("#%06x"):format(fg_hl.fg) })
-- 		statusline_hls[hl] = true
-- 	end
--
-- 	return hl_name
-- end

-- optimize the componet so that it is only called once
local cached_os_component = nil

local function build_os_component()
	local uv = vim.uv or vim.loop
	local uname_info = uv.os_uname() or {}
	local sysname = uname_info.sysname or "Unknown"

	local icon = user.os[sysname]

	if not icon then
		icon = "󱚟" -- fallback icon
	end

	return string.format(" %%#%s#%s", sysname, icon)
end

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		if not cached_os_component then
			cached_os_component = build_os_component()
		end
	end,
})

function M.os_component()
	return cached_os_component or ""
end

local mode_to_str = {
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

-- Mode component with vim mode mappings
---@return string
function M.mode_component()
	-- Note that: \19 = ^S and \22 = ^V.

	-- Get the respective string to display.
	local mode = mode_to_str[vim.api.nvim_get_mode().mode] or "UNKNOWN"

	-- Set the highlight group.
	local hl = "Other"
	if mode:find("NORMAL") then
		hl = "Normal"
	elseif mode:find("PENDING") then
		hl = "Pending"
	elseif mode:find("VISUAL") then
		hl = "Visual"
	elseif mode:find("INSERT") or mode:find("SELECT") then
		hl = "Insert"
	elseif mode:find("COMMAND") or mode:find("TERMINAL") or mode:find("EX") then
		hl = "Command"
	end

	-- Construct the bubble-like component.
	return table.concat({
		string.format("%%#StatuslineModeSeparator%s#", hl),
		string.format("%%#StatuslineMode%s#%s", hl, mode),
		string.format("%%#StatuslineModeSeparator%s#", hl),
	})
end

-- Git component
---@return string
function M.git_head()
	local head = vim.b.gitsigns_head
	if not head or head == "" then
		return ""
	end

	return string.format(" %s", head)
end

function M.git_status()
	local git_info = vim.b.gitsigns_status_dict
	if not git_info or git_info.head == "" then
		return ""
	end

	-- Helper function to build status strings
	local function format_status(count, highlight, symbol)
		return (count and count > 0) and ("%#" .. highlight .. "#" .. symbol .. count .. " ") or ""
	end

	local added = format_status(git_info.added, "GitSignsAdd", "+")
	local changed = format_status(git_info.changed, "GitSignsChange", "~")
	local removed = format_status(git_info.removed, "GitSignsDelete", "-")

	return table.concat({ added, changed, removed })
end

function M.lsp_status()
	local attached_clients = vim.lsp.get_clients({ bufnr = 0 })
	if #attached_clients == 0 then
		return ""
	end

	-- Prepare to store LSP client names
	local names = {}

	for _, client in ipairs(attached_clients) do
		-- Handle Copilot specially
		if client.name:lower():match("copilot") then
			if vim.g.copilot_enabled == 1 then
				table.insert(names, user.kinds.Copilot)
			end
		else
			-- Slight rename: trim "_language_server" => "_ls", e.g. "emmet_language_server" => "emmet_ls"
			local name = client.name:gsub("_language_server$", "_ls")
			table.insert(names, name)
		end
	end

	-- If the only attached server was Copilot but is disabled, names would be empty
	if #names == 0 then
		return ""
	end

	return string.format("%%#StatuslineLsp#%s", table.concat(names, ", "))
end

-- Pre-compute severity mapping for consistency
local DIAGNOSTIC_SEVERITY = vim.diagnostic.severity
local SEVERITY_NAMES = {
	[DIAGNOSTIC_SEVERITY.ERROR] = "ERROR",
	[DIAGNOSTIC_SEVERITY.WARN] = "WARN",
	[DIAGNOSTIC_SEVERITY.INFO] = "INFO",
	[DIAGNOSTIC_SEVERITY.HINT] = "HINT",
}

-- Cache for last computed component
local last_diagnostic_component = ""

-- Local helper function to create formatted diagnostic string
local function format_diagnostic(severity, count)
	local severity_name = SEVERITY_NAMES[severity]
	if not severity_name then
		return ""
	end

	-- Generate highlight name as in original: "DiagnosticError", "DiagnosticWarn", etc.
	local hl = "Diagnostic" .. severity_name:sub(1, 1) .. severity_name:sub(2):lower()
	local icon = user.signs[severity_name:lower()]

	return string.format("%%#%s#%s %d", hl, icon, count)
end

---@return string
function M.diagnostics_component()
	-- Quick returns for special cases
	if vim.bo.filetype == "lazy" then
		return ""
	end

	local mode = vim.api.nvim_get_mode().mode
	if mode:match("^i") then
		return last_diagnostic_component
	end

	-- Get diagnostics for current buffer
	local diagnostics = vim.diagnostic.get(0)
	if #diagnostics == 0 then
		last_diagnostic_component = ""
		return ""
	end

	-- Use a numeric array for counts to avoid string keys
	local counts = { 0, 0, 0, 0 } -- ERROR, WARN, INFO, HINT

	-- Count diagnostics
	for _, diag in ipairs(diagnostics) do
		counts[diag.severity] = (counts[diag.severity] or 0) + 1
	end

	-- Build result only for non-zero counts
	local parts = {}
	for severity, count in ipairs(counts) do
		if count > 0 then
			parts[#parts + 1] = format_diagnostic(severity, count)
		end
	end

	last_diagnostic_component = table.concat(parts, " ")
	return last_diagnostic_component
end

-- Cache for filetype components, keyed by filetype
local filetype_cache = {}

local function compute_filetype_component(filetype, buf_name)
	local devicons = require("nvim-web-devicons")

	if filetype == "" then
		filetype = "[No Name]"
	end

	-- Get icon and highlight
	local name = vim.fn.fnamemodify(buf_name, ":t")
	local ext = vim.fn.fnamemodify(buf_name, ":e")
	local icon, icon_hl = devicons.get_icon(name, ext)

	-- Fall back to filetype-based icon if needed
	if not icon then
		icon, icon_hl = devicons.get_icon_by_filetype(filetype, { default = true })
	end

	return string.format("%%#%s#%s %%#StatuslineTitle#%s", icon_hl, icon, filetype)
end

-- Simply clear the cache for the filetype when buffer is deleted
vim.api.nvim_create_autocmd("BufDelete", {
	group = augroup("StatuslineFiletype"),
	callback = function(opts)
		local deleted_ft = vim.bo[opts.buf].filetype
		filetype_cache[deleted_ft] = nil
	end,
})

-- The actual component function that gets called by the statusline
function M.filetype_component()
	local bufnr = vim.api.nvim_get_current_buf()
	local filetype = vim.bo.filetype
	local buf_name = vim.api.nvim_buf_get_name(bufnr)

	-- Return cached result if available for this filetype
	if filetype_cache[filetype] then
		return filetype_cache[filetype]
	end

	-- Compute and cache the result
	filetype_cache[filetype] = compute_filetype_component(filetype, buf_name)
	return filetype_cache[filetype]
end

-- Cache for encoding string and the actual encoding value
local cached_encoding = {
	formatted = "", -- The formatted string for statusline
	value = "", -- The actual encoding value
}

-- Setup autocommand to update encoding cache
vim.api.nvim_create_autocmd("BufEnter", {
	group = augroup("StatuslineEncoding"),
	callback = function(args)
		local bufnr = args.buf

		-- Skip if it's not a normal file buffer (e.g., help, terminal, quickfix)
		if vim.bo[bufnr].buftype ~= "" then
			if cached_encoding.value ~= "" then
				cached_encoding.formatted = ""
				cached_encoding.value = ""
			end
			return
		end

		-- Skip if the buffer has no name
		local buf_name = vim.api.nvim_buf_get_name(bufnr)
		if buf_name == "" then
			if cached_encoding.value ~= "" then
				cached_encoding.formatted = ""
				cached_encoding.value = ""
			end
			return
		end

		-- Get the current encoding
		local current_encoding = vim.opt.fileencoding:get()

		-- Only update cache if encoding has changed
		if current_encoding ~= cached_encoding.value then
			cached_encoding.value = current_encoding
			if current_encoding ~= "" then
				cached_encoding.formatted = string.format("%%#StatuslineModeSeparatorOther# %s", current_encoding)
			else
				cached_encoding.formatted = ""
			end
		end
	end,
})

--- Return the cached encoding string (instant lookup).
---@return string
function M.encoding_component()
	return cached_encoding.formatted
end

local cached_file_size = ""

local suffixes = { "B", "KB", "MB", "GB" }

local function update_file_size(bufnr)
	local file_path = vim.api.nvim_buf_get_name(bufnr)
	-- Skip empty (unnamed) buffers
	if file_path == "" then
		cached_file_size = ""
		return
	end

	-- Get actual file size
	local file_size = vim.fn.getfsize(file_path)
	if file_size <= 0 then
		cached_file_size = ""
		return
	end

	local i = 1

	-- Scale down file_size until it fits into a readable suffix
	while file_size > 1024 and i < #suffixes do
		file_size = file_size / 1024
		i = i + 1
	end

	local fmt = (i == 1) and "%d%s" or "%.1f%s"
	cached_file_size = string.format(fmt, file_size, suffixes[i])
end

-- Update file size whenever entering a buffer or writing to it
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
	group = augroup("StatuslineFileSize"),
	callback = function(args)
		update_file_size(args.buf)
	end,
})

-- Statusline component that just returns the cached value
function M.filesize_component()
	return cached_file_size
end

--- The current line, total line count, and column position.
---@return string
function M.position_component()
	local line = vim.fn.line(".")
	local line_count = vim.api.nvim_buf_line_count(0)

	return table.concat({
		"%#StatuslineItalic#l: ",
		string.format("%%#StatuslineTitle#%d", line),
		string.format("%%#StatuslineItalic#/%d", line_count),
	})
end

local macro_recording_text = ""

-- When macro recording starts (q<reg>), Neovim fires "RecordingEnter".
vim.api.nvim_create_autocmd("RecordingEnter", {
	group = augroup("StatuslineMacroEnter"),
	callback = function()
		local reg = vim.fn.reg_recording()
		if reg ~= "" then
			macro_recording_text = string.format("%%#StatuslineMacro#Recording @%s", reg)
		end
	end,
})

-- When macro recording stops, Neovim fires "RecordingLeave".
vim.api.nvim_create_autocmd("RecordingLeave", {
	group = augroup("StatuslineMacroLeave"),
	callback = function()
		-- Clear out the string so nothing is shown in the statusline.
		macro_recording_text = ""
	end,
})

--- Returns the cached macro recording text ("" if not recording).
---@return string
function M.macro_recording_component()
	return macro_recording_text
end

-- Main render function
---@return string
function M.render()
	local current_ft = vim.bo.filetype
	for _, ft in ipairs(user.excluded_filetypes) do
		if current_ft == ft then
			return "" -- Return an empty string to disable the statusline
		end
	end

	---@param components string[]
	---@return string
	local function concat_components(components)
		return vim.iter(components):skip(1):fold(components[1], function(acc, component)
			return #component > 0 and string.format("%s  %s", acc, component) or acc
		end)
	end

	return table.concat({
		concat_components({
			M.os_component(),
			M.mode_component(),
			M.git_head(),
			M.lsp_status(),
			M.git_status(),
		}),
		"%#Statusline#%=",
		concat_components({
			M.macro_recording_component(),
			M.diagnostics_component(),
			M.filetype_component(),
			M.encoding_component(),
			M.filesize_component(),
			M.position_component(),
		}),
		" ",
	})
end
-- Set up the statusline
vim.opt.statusline = "%!v:lua.require'aqothy.config.statusline'.render()"

return M
