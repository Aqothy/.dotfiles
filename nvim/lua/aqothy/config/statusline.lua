local M = {}

local api = vim.api
local uv = vim.uv or vim.loop
local fn = vim.fn
local cmd = vim.cmd

local stl_group = api.nvim_create_augroup("aqline", { clear = true })
local autocmd = api.nvim_create_autocmd

local user = require("aqothy.config.icons")
local mini_icons = require("mini.icons")

M.sysname = uv.os_uname().sysname or ""

M.os_cache = nil

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

-- For op-pending mode
autocmd("ModeChanged", {
    group = stl_group,
    desc = "Update statusline on mode change",
    callback = vim.schedule_wrap(function()
        cmd("redrawstatus")
    end),
})

function M.mode_component()
    local mode = api.nvim_get_mode().mode
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
    local head = "%#Statusline# " .. git_info.head

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
autocmd("DiagnosticChanged", {
    group = stl_group,
    callback = function(data)
        if api.nvim_buf_is_valid(data.buf) then
            M.diagnostic_counts[data.buf] = vim.diagnostic.count(data.buf)
        else
            M.diagnostic_counts[data.buf] = nil
        end
        -- Invalidate string cache for this buffer
        M.diagnostic_str_cache[data.buf] = nil
    end,
    desc = "Track diagnostics",
})

function M.diagnostics_component()
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

    M.diagnostic_str_cache[buf] = (#parts > 0) and table.concat(parts, " ") or ""
    return M.diagnostic_str_cache[buf]
end

M.lsp_clients_cache = {}

M.formatters_cache = {}
M.file_info_cache = {}

autocmd({ "LspAttach", "LspDetach" }, {
    group = stl_group,
    callback = function(args)
        M.lsp_clients_cache[args.buf] = nil
    end,
    desc = "Invalidate LSP clients cache",
})

autocmd("OptionSet", {
    group = stl_group,
    pattern = { "fileencoding", "expandtab", "tabstop" },
    callback = function(args)
        M.file_info_cache[args.buf] = nil
    end,
    desc = "Invalidate file info cache on option change",
})

-- Garbage collect
autocmd({ "BufDelete", "FileType" }, {
    group = stl_group,
    callback = function(args)
        M.formatters_cache[args.buf] = nil
        M.file_info_cache[args.buf] = nil
    end,
    desc = "Clean up cache",
})

function M.lsp_clients_component()
    local buf = api.nvim_get_current_buf()
    if M.lsp_clients_cache[buf] then
        return M.lsp_clients_cache[buf]
    end

    local clients = vim.lsp.get_clients({ bufnr = buf })
    if #clients == 0 then
        M.lsp_clients_cache[buf] = ""
        return ""
    end

    local client_names = {}
    for _, client in ipairs(clients) do
        if client.name:lower():match("copilot") then
            table.insert(client_names, user.kinds.Copilot)
        else
            table.insert(client_names, client.name)
        end
    end

    M.lsp_clients_cache[buf] = #client_names > 0 and "%#Statusline#" .. table.concat(client_names, ", ") or ""
    return M.lsp_clients_cache[buf]
end

function M.formatters_component()
    local buf = api.nvim_get_current_buf()
    if M.formatters_cache[buf] then
        return M.formatters_cache[buf]
    end

    local ok, conform = pcall(require, "conform")
    if not ok then
        M.formatters_cache[buf] = ""
        return ""
    end

    local formatters = conform.list_formatters(buf)
    if #formatters == 0 then
        M.formatters_cache[buf] = ""
        return ""
    end

    local formatter_names = {}
    for _, formatter in ipairs(formatters) do
        table.insert(formatter_names, formatter.name)
    end

    M.formatters_cache[buf] = "%#Statusline#" .. table.concat(formatter_names, ", ")
    return M.formatters_cache[buf]
end

function M.file_info_component()
    local buf = api.nvim_get_current_buf()
    if M.file_info_cache[buf] then
        return M.file_info_cache[buf]
    end

    local bo_buf = vim.bo[buf]
    M.file_info_cache[buf] = "%#StatuslineModeSeparatorOther#"
        .. bo_buf.fileencoding
        .. (bo_buf.expandtab and " Spaces:" or " Tab:")
        .. bo_buf.tabstop

    return M.file_info_cache[buf]
end

function M.render()
    local git_head, git_status = M.git_components()

    local left_components = {}
    local left_candidates = {
        M.os_component(),
        M.mode_component(),
        git_head,
        M.lsp_clients_component(),
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
        M.formatters_component(),
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
