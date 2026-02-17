local M = {}

local api = vim.api
local bo = vim.bo
local fn = vim.fn
local cmd = vim.cmd
local uv = vim.uv or vim.loop

local stl_group = "aqline"
local autocmd = api.nvim_create_autocmd

local has_icons, icons = pcall(require, "config.icons")
local mini_icons_mod = nil

local function get_mini_icons()
    if mini_icons_mod == false then
        return nil
    end
    if mini_icons_mod then
        return mini_icons_mod
    end

    local ok, mod = pcall(require, "mini.icons")
    mini_icons_mod = ok and mod or false
    return ok and mod or nil
end

local function get_sidekick_status()
    return package.loaded["sidekick.status"]
end

local groups = {}

local function stl_escape(str)
    if not str or str == "" then
        return str
    end
    return str:gsub("%%", "%%%%")
end

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
groups["AqlineLspLoading"] = { link = "DiagnosticInfo" }
groups["AqlineLspDone"] = { link = "DiagnosticOk" }

local function setup_highlights()
    for group, opts in pairs(groups) do
        opts.default = true
        vim.api.nvim_set_hl(0, group, opts)
    end
end

local os_uname = uv.os_uname()

M.sysname = fn.has("win32") == 1 and "windows" or (os_uname.sysname == "Darwin" and "macos" or os_uname.sysname:lower())

M.os_cache = nil

function M.os_component()
    if not M.os_cache then
        local mini_icons = get_mini_icons()
        if mini_icons then
            local icon, icon_hl = mini_icons.get("os", M.sysname)
            M.os_cache = "%#" .. icon_hl .. "#" .. icon
        else
            return ""
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
        or ("%#AqlineMode" .. hl .. "# " .. mode_str .. " %*")

    M.mode_hl_cache.short[mode_str] = M.mode_hl_cache.short[mode_str]
        or ("%#AqlineMode" .. hl .. "# " .. data.short .. " %*")
end

function M.mode_component()
    local mode = api.nvim_get_mode().mode
    local mode_data = M.MODE_MAP[mode] or { long = "UNKNOWN", short = "U" }
    local mode_str = mode_data.long

    local use_short = M.win_width and M.win_width < 120
    local cache = use_short and M.mode_hl_cache.short[mode_str] or M.mode_hl_cache.long[mode_str]

    return cache or ("%#AqlineModeOther# " .. (use_short and mode_data.short or mode_str) .. " %*")
end

function M.git_components()
    local git_info = vim.b.gitsigns_status_dict
    if not git_info then
        return "", ""
    end

    local branch_name = git_info.head and git_info.head ~= "" and stl_escape(git_info.head) or ""
    local branch = branch_name ~= "" and ("%* " .. branch_name) or ""

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
    local ft = bo[buf].filetype

    local icon, icon_hl
    local mini_icons = get_mini_icons()
    if mini_icons then
        local is_default
        icon, icon_hl, is_default = mini_icons.get("filetype", ft)
        if is_default then
            icon, icon_hl = mini_icons.get("file", relative_path)
        end
    end

    icon = icon or "󰈔"
    icon_hl = icon_hl and ("%#" .. icon_hl .. "#") or "%*"

    -- Only truncate if not empty and not a terminal buffer
    local buftype = bo[buf].buftype
    local display_path
    if relative_path ~= "" and buftype ~= "terminal" then
        display_path = stl_escape(M.truncate_path(relative_path, 40))
    else
        display_path = "%t" -- Use only the filename
    end

    local result = icon_hl .. icon .. "%* " .. display_path .. " %m%r"

    if buftype == "" and mini_icons ~= nil then
        M.file_cache[buf] = result
    end

    return result
end

local diag_signs = has_icons and icons.diagnostics or { Error = "●", Warn = "●", Info = "●", Hint = "●" }
M.diagnostic_levels = {
    { name = "ERROR", sign = diag_signs.Error, hl = "DiagnosticError" },
    { name = "WARN", sign = diag_signs.Warn, hl = "DiagnosticWarn" },
    { name = "INFO", sign = diag_signs.Info, hl = "DiagnosticInfo" },
    { name = "HINT", sign = diag_signs.Hint, hl = "DiagnosticHint" },
}
M.diagnostic_str_cache = {}

function M.diagnostics_component()
    local buf = api.nvim_get_current_buf()

    if M.diagnostic_str_cache[buf] then
        return M.diagnostic_str_cache[buf]
    end

    local count = vim.diagnostic.count(buf)

    local buftype = bo[buf].buftype

    if not next(count) then
        if buftype == "" then
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

    if buftype == "" then
        M.diagnostic_str_cache[buf] = result
    end

    return result
end

M.lsp_progress_state = {}
M.lsp_progress_cached_str = ""

local function update_lsp_progress_str()
    local parts = {}
    -- sort so that the order is consistent
    local keys = vim.tbl_keys(M.lsp_progress_state)
    table.sort(keys)

    for _, k in ipairs(keys) do
        local state = M.lsp_progress_state[k]
        local icon = state.is_done and "" or "󱥸"
        local hl = state.is_done and "%#AqlineLspDone#" or "%#AqlineLspLoading#"
        parts[#parts + 1] = hl .. stl_escape(state.name) .. " " .. icon .. "%*"
    end
    M.lsp_progress_cached_str = table.concat(parts, " ")
end

function M.lsp_progress_component()
    return M.lsp_progress_cached_str
end

M.copilot_icons = {
    Error = { text = "", hl = "DiagnosticError" },
    Inactive = { text = "", hl = "Comment" },
    Warning = { text = "", hl = "DiagnosticWarn" },
    Normal = { text = "", hl = "Special" },
}

function M.copilot_component()
    local sidekick = get_sidekick_status()
    if not sidekick then
        return ""
    end

    local status = sidekick.get()
    if not status then
        return ""
    end

    local config = M.copilot_icons[status.kind] or M.copilot_icons.Normal

    local hl = status.busy and "DiagnosticWarn" or config.hl

    return "%#" .. hl .. "#" .. config.text .. "%*"
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

    local result = "%*" .. format_filesize(size)

    if bo[buf].buftype == "" then
        M.file_size_cache[buf] = result
    end

    return result
end

function M.file_info_component()
    local buf = api.nvim_get_current_buf()
    if M.file_info_cache[buf] then
        return M.file_info_cache[buf]
    end

    local buf_opts = bo[buf]
    local result = "%#AqlineFileInfo#"
        .. buf_opts.fileencoding
        .. (buf_opts.expandtab and " Spaces:" or " Tab:")
        .. buf_opts.tabstop

    if buf_opts.buftype == "" then
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

    if git_changes ~= "" then
        parts[#parts + 1] = git_changes
    end

    parts[#parts + 1] = "%*%="

    local lsp_progress = M.lsp_progress_component()
    if lsp_progress ~= "" then
        parts[#parts + 1] = lsp_progress
    end

    local diag = M.diagnostics_component()
    if diag ~= "" then
        parts[#parts + 1] = diag
    end

    if width > 120 then
        local copilot_status = M.copilot_component()
        if copilot_status ~= "" then
            parts[#parts + 1] = copilot_status
        end

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

local function create_autocmds()
    -- For op-pending mode
    autocmd("ModeChanged", {
        group = stl_group,
        desc = "Update statusline on mode change",
        callback = vim.schedule_wrap(function()
            cmd("redrawstatus")
        end),
    })

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

    autocmd("OptionSet", {
        group = stl_group,
        pattern = { "filetype" },
        callback = function()
            local buf = api.nvim_get_current_buf()
            M.file_cache[buf] = nil
            M.file_info_cache[buf] = nil
        end,
        desc = "Invalidate file cache on filetype change",
    })

    autocmd("BufDelete", {
        group = stl_group,
        callback = function(ev)
            local buf = ev.buf
            M.file_cache[buf] = nil
            M.file_info_cache[buf] = nil
            M.file_size_cache[buf] = nil
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

    autocmd("DiagnosticChanged", {
        group = stl_group,
        callback = function(ev)
            local buf = ev.buf
            M.diagnostic_str_cache[buf] = nil
            vim.schedule(function()
                vim.cmd("redrawstatus")
            end)
        end,
        desc = "Track diagnostics",
    })

    autocmd("LspProgress", {
        group = stl_group,
        pattern = { "begin", "end" },
        callback = function(ev)
            local client_id = ev.data.client_id
            local client = vim.lsp.get_client_by_id(client_id)
            if not client then
                return
            end

            local value = ev.data.params.value
            local is_end = value.kind == "end"

            -- cancel existing cleanup timers
            if M.lsp_progress_state[client_id] and M.lsp_progress_state[client_id].timer then
                M.lsp_progress_state[client_id].timer:close()
            end

            M.lsp_progress_state[client_id] = {
                name = client.name,
                is_done = is_end,
                timer = nil,
            }

            if is_end then
                M.lsp_progress_state[client_id].timer = vim.defer_fn(function()
                    M.lsp_progress_state[client_id] = nil
                    update_lsp_progress_str()
                    vim.cmd("redrawstatus")
                end, 3000)
            end

            update_lsp_progress_str()
            vim.cmd("redrawstatus")
        end,
    })

    autocmd("OptionSet", {
        group = stl_group,
        pattern = { "fileencoding", "expandtab", "tabstop" },
        callback = function()
            local buf = api.nvim_get_current_buf()
            M.file_info_cache[buf] = nil
        end,
        desc = "Invalidate file info cache on option change",
    })

    autocmd({ "VimResized", "WinResized", "WinEnter" }, {
        group = stl_group,
        callback = function()
            M.win_width = nil
        end,
        desc = "Invalidate window width cache",
    })
end

function M.setup()
    api.nvim_create_augroup(stl_group, { clear = true })
    setup_highlights()
    create_autocmds()

    -- vim.opt.laststatus = 3
    -- vim.g.qf_disable_statusline = 1
    vim.opt.showmode = false
    vim.opt.ruler = false
    vim.opt.statusline =
        "%{%(nvim_get_current_win()==#g:actual_curwin || &laststatus==3) ? v:lua.require'custom.statusline'.render() : v:lua.require'custom.statusline'.render_inactive()%}"
end

return M
