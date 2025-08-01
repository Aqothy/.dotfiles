local M = {}

local api = vim.api
local bo = vim.bo
local uv = vim.uv or vim.loop
local fn = vim.fn
local cmd = vim.cmd

local stl_group = api.nvim_create_augroup("aqline", { clear = true })
local autocmd = api.nvim_create_autocmd

local user = require("aqothy.config.icons")
local mini_icons = require("mini.icons")

M.sysname = uv.os_uname().sysname or ""

function M.os_component()
    if not M.os_cache then
        if fn.has("win32") == 1 then
            M.sysname = "windows"
        else
            M.sysname = (M.sysname == "Darwin") and "macos" or M.sysname:lower()
        end
        local icon, icon_hl = mini_icons.get("os", M.sysname)
        M.os_cache = "%#" .. icon_hl .. "#" .. icon
    end
    return M.os_cache
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
    ["D"] = "DEBUG",
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
    DEBUG = "Debug",
}

-- Debug mode component
local dmode_enabled = false
autocmd("User", {
    pattern = "DebugModeChanged",
    callback = function(args)
        dmode_enabled = args.data.enabled
        cmd("redrawstatus")
    end,
    desc = "Toggle debug mode in statusline",
})

-- For op-pending mode
autocmd("ModeChanged", {
    group = stl_group,
    desc = "Update statusline on mode change",
    callback = vim.schedule_wrap(function()
        cmd("redrawstatus")
    end),
})

function M.mode_component()
    local mode = dmode_enabled and "D" or api.nvim_get_mode().mode
    local mode_str = M.MODE_MAP[mode] or "UNKNOWN"
    local hl = M.MODE_TO_HIGHLIGHT[mode_str] or "Other"
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
    local head = "%#StatuslineTitle# " .. git_info.head

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

function M.get_diagnostic_count(buf_id)
    return vim.diagnostic.count(buf_id)
end

-- Only get counts when needed instead of on every change
autocmd("DiagnosticChanged", {
    group = stl_group,
    callback = function(data)
        if api.nvim_buf_is_valid(data.buf) then
            M.diagnostic_counts[data.buf] = M.get_diagnostic_count(data.buf)
        else
            M.diagnostic_counts[data.buf] = nil
        end
        -- Invalidate string cache for this buffer
        M.diagnostic_str_cache[data.buf] = nil
    end,
    desc = "Track diagnostics",
})

function M.diagnostics_component()
    if bo.filetype == "lazy" or bo.filetype == "mason" then
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

---@type table<string, {kind: string, client: string}>
M.progress_statuses = {}
M.progress_cache = nil
M.progress_dirty = true

autocmd("LspProgress", {
    group = stl_group,
    desc = "Update LSP progress in statusline",
    pattern = { "begin", "end" },
    callback = function(args)
        local data = args.data
        if not data then
            return
        end

        local client_id = data.client_id
        local client = vim.lsp.get_client_by_id(client_id)
        local value = data.params.value

        if not client or type(value) ~= "table" then
            return
        end

        local progress = value.kind

        -- Mark cache as dirty to trigger rebuild
        M.progress_dirty = true

        local client_key = client.name .. client_id

        M.progress_statuses[client_key] = {
            kind = progress,
            client = client.name,
        }

        if progress == "end" then
            vim.defer_fn(function()
                M.progress_statuses[client_key] = nil
                M.progress_dirty = true
                cmd.redrawstatus()
            end, 3000)
        end

        cmd.redrawstatus()
    end,
})

function M.lsp_progress_component()
    -- Return cached result if not dirty
    if not M.progress_dirty and M.progress_cache then
        return M.progress_cache
    end

    local progress_parts = {}
    for _, status in pairs(M.progress_statuses) do
        if status then
            local is_done = status.kind == "end"
            local symbol = is_done and " " or "󱥸 "
            table.insert(progress_parts, "%#StatuslineTitle#" .. symbol .. status.client)
        end
    end

    M.progress_cache = table.concat(progress_parts, " ")
    M.progress_dirty = false

    return M.progress_cache
end

autocmd({ "BufEnter", "WinEnter", "BufWritePost", "TermLeave" }, {
    group = stl_group,
    callback = function()
        M.file_cache = nil
        M.file_info = nil
    end,
    desc = "Invalidate file cache",
})

function M.truncate_path(path, max_len)
    if #path <= max_len or path == "" then
        return path
    end

    local sep = M.sysname == "windows" and "\\" or "/"
    local parts = {}
    for part in string.gmatch(path, "[^" .. sep .. "]+") do
        table.insert(parts, part)
    end

    -- Keep first dir and filename intact, abbreviate middle parts if needed
    if #parts <= 2 then
        return path -- If only one directory deep or less, return full path
    end

    local first = parts[1]
    local last = parts[#parts]
    return first .. sep .. "…" .. sep .. last
end

function M.get_filetype_cache()
    local relative_path = fn.expand("%:.")
    local icon, icon_hl = mini_icons.get("file", relative_path)

    -- Only truncate if not empty and not a terminal buffer
    local display_path = relative_path
    if relative_path ~= "" and bo.buftype ~= "terminal" then
        display_path = M.truncate_path(relative_path, 40)
    else
        display_path = "%t" -- Use only the filename
    end

    M.file_cache = "%#" .. icon_hl .. "#" .. icon .. " %#StatuslineTitle#" .. display_path .. "%m%r"
end

function M.filetype_component()
    if not M.file_cache then
        M.get_filetype_cache()
    end
    return M.file_cache
end

autocmd("OptionSet", {
    group = stl_group,
    pattern = { "fileencoding", "expandtab", "tabstop" },
    callback = function()
        M.file_info = nil
    end,
    desc = "Invalidate file info cache",
})

function M.get_file_info()
    M.file_info = "%#StatuslineModeSeparatorOther# "
        .. bo.fileencoding
        .. (bo.expandtab and " Spaces:" or " Tab:")
        .. bo.tabstop
end

function M.file_info_component()
    if not M.file_info then
        M.get_file_info()
    end
    return M.file_info
end

function M.position_component()
    local line_count = api.nvim_buf_line_count(0)
    return "%#StatuslineItalic#Ln " .. "%#StatuslineTitle#%l" .. "%#StatuslineItalic#/" .. line_count .. " Col %c"
end

function M.render()
    local git_head, git_status = M.git_components()

    local left_components = {}
    local left_candidates = {
        -- M.os_component(),
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
        M.position_component(),
        M.file_info_component(),
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

vim.g.qf_disable_statusline = 1
vim.opt.showmode = false
vim.opt.ruler = false
vim.opt.laststatus = 3
vim.opt.statusline = "%!v:lua.require'aqothy.config.statusline'.render()"

return M
