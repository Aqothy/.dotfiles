local M = {}

local api = vim.api
local bo = vim.bo
local fn = vim.fn
local cmd = vim.cmd
local uv = vim.uv or vim.loop

local stl_group = api.nvim_create_augroup("aqline", { clear = true })
local autocmd = api.nvim_create_autocmd

local has_icons, icons = pcall(require, "aqothy.config.icons")
local has_mini_icons, mini_icons = pcall(require, "mini.icons")

local groups = {}

local mode_colors = {
    Normal = "Cursor",
    Pending = "PMenuSel",
    Replace = "Substitute",
    Visual = "Visual",
    Insert = "DiffAdd",
    Command = "IncSearch",
    Other = "ErrorMsg",
}

for mode, color in pairs(mode_colors) do
    groups["AqlineMode" .. mode] = { link = color }
end

groups["AqlineFileInfo"] = { link = "QuickFixLine" }

for group, opts in pairs(groups) do
    opts.default = true
    vim.api.nvim_set_hl(0, group, opts)
end

-- vim.opt.laststatus = 3

local os_uname = uv.os_uname()

M.sysname = fn.has("win32") == 1 and "windows" or (os_uname.sysname == "Darwin" and "macos" or os_uname.sysname:lower())

M.os_cache = nil

function M.os_component()
    if not M.os_cache then
        if has_mini_icons then
            local icon, icon_hl = mini_icons.get("os", M.sysname)
            M.os_cache = "%#" .. icon_hl .. "#" .. icon
        else
            M.os_cache = ""
        end
    end
    return M.os_cache
end

M.MODE_MAP = {
    ["n"] = { long = "NORMAL", short = "N" },
    ["niI"] = { long = "NORMAL", short = "N" },
    ["niR"] = { long = "NORMAL", short = "N" },
    ["niV"] = { long = "NORMAL", short = "N" },
    ["nt"] = { long = "NORMAL", short = "N" },
    ["ntT"] = { long = "NORMAL", short = "N" },
    ["no"] = { long = "OP-PENDING", short = "O" },
    ["nov"] = { long = "OP-PENDING", short = "O" },
    ["noV"] = { long = "OP-PENDING", short = "O" },
    ["no\22"] = { long = "OP-PENDING", short = "O" },
    ["v"] = { long = "VISUAL", short = "V" },
    ["vs"] = { long = "VISUAL", short = "V" },
    ["V"] = { long = "V-LINE", short = "VL" },
    ["Vs"] = { long = "V-LINE", short = "VL" },
    ["\22"] = { long = "V-BLOCK", short = "VB" },
    ["\22s"] = { long = "V-BLOCK", short = "VB" },
    ["s"] = { long = "SELECT", short = "S" },
    ["S"] = { long = "SELECT", short = "S" },
    ["\19"] = { long = "SELECT", short = "S" },
    ["i"] = { long = "INSERT", short = "I" },
    ["ic"] = { long = "INSERT", short = "I" },
    ["ix"] = { long = "INSERT", short = "I" },
    ["R"] = { long = "REPLACE", short = "R" },
    ["Rc"] = { long = "REPLACE", short = "R" },
    ["Rx"] = { long = "REPLACE", short = "R" },
    ["Rv"] = { long = "V-REPLACE", short = "VR" },
    ["Rvc"] = { long = "V-REPLACE", short = "VR" },
    ["Rvx"] = { long = "V-REPLACE", short = "VR" },
    ["c"] = { long = "COMMAND", short = "C" },
    ["cv"] = { long = "EX", short = "EX" },
    ["ce"] = { long = "EX", short = "EX" },
    ["r"] = { long = "REPLACE", short = "R" },
    ["rm"] = { long = "MORE", short = "M" },
    ["r?"] = { long = "CONFIRM", short = "?" },
    ["!"] = { long = "SHELL", short = "SH" },
    ["t"] = { long = "TERMINAL", short = "T" },
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

M.mode_hl_cache = { long = {}, short = {} }
for _, data in pairs(M.MODE_MAP) do
    local mode_str = data.long
    local hl = M.MODE_TO_HIGHLIGHT[mode_str] or "Other"

    M.mode_hl_cache.long[mode_str] = M.mode_hl_cache.long[mode_str]
        or ("%#AqlineMode" .. hl .. "# " .. mode_str .. " %0*")

    M.mode_hl_cache.short[mode_str] = M.mode_hl_cache.short[mode_str]
        or ("%#AqlineMode" .. hl .. "# " .. data.short .. " %0*")
end

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
    local mode_data = M.MODE_MAP[mode] or { long = "UNKNOWN", short = "U" }
    local mode_str = mode_data.long

    local use_short = M.win_width and M.win_width < 120
    local cache = use_short and M.mode_hl_cache.short[mode_str] or M.mode_hl_cache.long[mode_str]

    return cache or ("%#AqlineModeOther# " .. (use_short and mode_data.short or mode_str) .. " %0*")
end

function M.git_components()
    local git_info = vim.b.gitsigns_status_dict
    if not git_info then
        return "", ""
    end

    local branch = (git_info.head and git_info.head ~= "") and ("%0* " .. git_info.head) or ""

    local status_parts = {}
    local git_icons = has_icons and icons.git or { added = "+", modified = "~", removed = "-" }

    if git_info.added and git_info.added > 0 then
        status_parts[#status_parts + 1] = "%#GitSignsAdd#" .. git_icons.added .. " " .. git_info.added
    end
    if git_info.changed and git_info.changed > 0 then
        status_parts[#status_parts + 1] = "%#GitSignsChange#" .. git_icons.modified .. " " .. git_info.changed
    end
    if git_info.removed and git_info.removed > 0 then
        status_parts[#status_parts + 1] = "%#GitSignsDelete#" .. git_icons.removed .. " " .. git_info.removed
    end

    local changes = (#status_parts > 0) and table.concat(status_parts, " ") or ""

    return branch, changes
end

M.file_cache = {}
M.file_info_cache = {}
M.file_size_cache = {}

autocmd({ "BufEnter", "BufWritePost", "FileChangedShellPost" }, {
    group = stl_group,
    callback = function(ev)
        local buf = ev.buf
        M.file_cache[buf] = nil
        M.file_info_cache[buf] = nil
        M.file_size_cache[buf] = nil
    end,
    desc = "Invalidate file cache",
})

autocmd("BufDelete", {
    group = stl_group,
    callback = function(ev)
        local buf = ev.buf
        M.file_cache[buf] = nil
        M.file_info_cache[buf] = nil
        M.file_size_cache[buf] = nil
        M.diagnostic_counts[buf] = nil
        M.diagnostic_str_cache[buf] = nil
    end,
    desc = "Cleanup buffer caches",
})

autocmd("DirChanged", {
    group = stl_group,
    callback = function(ev)
        M.file_cache[ev.buf] = nil
    end,
    desc = "Invalidate file cache on directory change",
})

local path_sep = M.sysname == "windows" and "\\" or "/"

function M.truncate_path(path, max_len)
    if #path <= max_len or path == "" then
        return path
    end

    local parts = {}
    for part in string.gmatch(path, "[^" .. path_sep .. "]+") do
        parts[#parts + 1] = part
    end

    -- Keep first dir and filename intact, abbreviate middle parts if needed
    if #parts <= 2 then
        return path -- If only one directory deep or less, return full path
    end

    local first = parts[1]
    local last = parts[#parts]
    return first .. path_sep .. "…" .. path_sep .. last
end

function M.filetype_component()
    local buf = api.nvim_get_current_buf()
    if M.file_cache[buf] then
        return M.file_cache[buf]
    end

    local relative_path = fn.expand("%:.")

    local icon_part = "%0*󰈔 "
    if has_mini_icons then
        local icon, icon_hl = mini_icons.get("file", relative_path)
        icon_part = "%#" .. icon_hl .. "#" .. icon .. " "
    end

    -- Only truncate if not empty and not a terminal buffer
    local display_path
    if relative_path ~= "" and bo.buftype ~= "terminal" then
        display_path = M.truncate_path(relative_path, 40)
    else
        display_path = "%t" -- Use only the filename
    end

    local result = icon_part .. "%0*" .. display_path .. "%m%r"

    if bo.buftype == "" then
        M.file_cache[buf] = result
    end

    return result
end

local diag_signs = has_icons and icons.diagnostics or { Error = "E", Warn = "W", Info = "I", Hint = "H" }
M.diagnostic_levels = {
    { name = "ERROR", sign = diag_signs.Error, hl = "DiagnosticError" },
    { name = "WARN", sign = diag_signs.Warn, hl = "DiagnosticWarn" },
    { name = "INFO", sign = diag_signs.Info, hl = "DiagnosticInfo" },
    { name = "HINT", sign = diag_signs.Hint, hl = "DiagnosticHint" },
}
M.diagnostic_counts = {}
M.diagnostic_str_cache = {}

autocmd("DiagnosticChanged", {
    group = stl_group,
    callback = function(ev)
        local buf = ev.buf
        if api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" then
            M.diagnostic_counts[buf] = vim.diagnostic.count(buf)
        else
            M.diagnostic_counts[buf] = nil
        end
        M.diagnostic_str_cache[buf] = nil
    end,
    desc = "Track diagnostics",
})

function M.diagnostics_component()
    local buf = api.nvim_get_current_buf()

    if M.diagnostic_str_cache[buf] then
        return M.diagnostic_str_cache[buf]
    end

    local count = M.diagnostic_counts[buf]
    if not count then
        if bo.buftype == "" then
            M.diagnostic_str_cache[buf] = ""
        end
        return ""
    end

    local severity = vim.diagnostic.severity
    local parts = {}

    for i = 1, #M.diagnostic_levels do
        local level = M.diagnostic_levels[i]
        local n = count[severity[level.name]]
        if n and n > 0 then
            parts[#parts + 1] = "%#" .. level.hl .. "#" .. level.sign .. " " .. n
        end
    end

    local result = (#parts > 0) and table.concat(parts, " ") or ""

    if bo.buftype == "" then
        M.diagnostic_str_cache[buf] = result
    end

    return result
end

local function format_filesize(size)
    if size < 1000 then
        return string.format("%db", size)
    elseif size < 1000000 then
        return string.format("%.2fkb", size / 1000)
    else
        return string.format("%.2fmb", size / 1000000)
    end
end

M.filesize_component = function()
    local buf = api.nvim_get_current_buf()
    if M.file_size_cache[buf] then
        return M.file_size_cache[buf]
    end

    local size = fn.getfsize(fn.expand("%:p"))
    -- Handle new/unsaved files
    if size < 0 then
        size = 0
    end

    local result = "%0*" .. format_filesize(size)

    if bo.buftype == "" then
        M.file_size_cache[buf] = result
    end

    return result
end

autocmd("OptionSet", {
    group = stl_group,
    pattern = { "fileencoding", "expandtab", "tabstop" },
    callback = function()
        local buf = api.nvim_get_current_buf()
        M.file_info_cache[buf] = nil
    end,
    desc = "Invalidate file info cache on option change",
})

function M.file_info_component()
    local buf = api.nvim_get_current_buf()
    if M.file_info_cache[buf] then
        return M.file_info_cache[buf]
    end

    local result = "%#AqlineFileInfo#" .. bo.fileencoding .. (bo.expandtab and " Spaces:" or " Tab:") .. bo.tabstop

    if bo.buftype == "" then
        M.file_info_cache[buf] = result
    end

    return result
end

function M.render_inactive()
    local parts = {}

    local file_comp = M.filetype_component()
    if file_comp ~= "" then
        parts[#parts + 1] = file_comp
    end

    parts[#parts + 1] = "%#StatusLineNC#%="

    local diag = M.diagnostics_component()
    if diag ~= "" then
        parts[#parts + 1] = diag
    end

    return " " .. table.concat(parts, "  ") .. " "
end

function M.render()
    if not M.win_width then
        M.win_width = vim.o.laststatus == 3 and vim.o.columns or api.nvim_win_get_width(0)
    end

    local parts = { M.mode_component() }
    local width = M.win_width

    local git_branch, git_changes = M.git_components()
    if git_branch ~= "" then
        parts[#parts + 1] = git_branch
    end

    local file_comp = M.filetype_component()
    if file_comp ~= "" then
        parts[#parts + 1] = file_comp
    end

    if width > 100 and git_changes ~= "" then
        parts[#parts + 1] = git_changes
    end

    parts[#parts + 1] = "%0*%="

    local diag = M.diagnostics_component()
    if diag ~= "" then
        parts[#parts + 1] = diag
    end

    if width > 120 then
        local os_comp = M.os_component()
        if os_comp ~= "" then
            parts[#parts + 1] = os_comp
        end

        local filesize = M.filesize_component()
        if filesize ~= "" then
            parts[#parts + 1] = filesize
        end

        local file_info = M.file_info_component()
        if file_info ~= "" then
            parts[#parts + 1] = file_info
        end
    end

    return table.concat(parts, "  ") .. " "
end

M.win_width = nil

autocmd({ "VimResized", "WinResized", "WinEnter" }, {
    group = stl_group,
    callback = function()
        M.win_width = nil
    end,
    desc = "Invalidate window width cache",
})

vim.g.qf_disable_statusline = 1
vim.opt.showmode = false
vim.opt.ruler = false
vim.opt.statusline =
    "%{%(nvim_get_current_win()==#g:actual_curwin || &laststatus==3) ? v:lua.require'aqothy.config.statusline'.render() : v:lua.require'aqothy.config.statusline'.render_inactive()%}"

return M
