local M = {}

local api = vim.api
local has_icons, icons = pcall(require, "config.icons")
local mini_icons_mod = nil
local group = "AqTabline"
local autocmd = api.nvim_create_autocmd

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

M.file_cache = {}

local diag_signs = has_icons and icons.diagnostics or { Error = "●", Warn = "●", Info = "●", Hint = "●" }

local function stl_escape(str)
    if not str or str == "" then
        return str
    end
    return str:gsub("%%", "%%%%")
end

local path_sep = package.config:sub(1, 1)

local diag_severity_map = {
    [vim.diagnostic.severity.ERROR] = { sign = diag_signs.Error, hl = "DiagnosticError" },
    [vim.diagnostic.severity.WARN] = { sign = diag_signs.Warn, hl = "DiagnosticWarn" },
    [vim.diagnostic.severity.INFO] = { sign = diag_signs.Info, hl = "DiagnosticInfo" },
    [vim.diagnostic.severity.HINT] = { sign = diag_signs.Hint, hl = "DiagnosticHint" },
}

local function clear_buffer_cache(buf)
    M.file_cache[buf] = nil
end

local function get_title(buf)
    local cached = M.file_cache[buf] and M.file_cache[buf].title
    if cached then
        return cached
    end

    local bt = vim.bo[buf].buftype
    local name = api.nvim_buf_get_name(buf)
    local val
    if name == "" then
        val = bt ~= "" and bt or "[No Name]"
    else
        val = vim.fs.basename(name)
    end

    if bt == "" then
        M.file_cache[buf] = M.file_cache[buf] or {}
        M.file_cache[buf].title = val
    end
    return val
end

local function get_icon(buf, hl)
    local cached = M.file_cache[buf] and M.file_cache[buf].icon
    if cached then
        return cached.hl .. cached.icon .. hl .. " "
    end

    local ft = vim.bo[buf].filetype
    local icon, icon_hl
    local mini_icons = get_mini_icons()
    if mini_icons then
        local is_default
        icon, icon_hl, is_default = mini_icons.get("filetype", ft)
        if is_default then
            icon, icon_hl = mini_icons.get("file", api.nvim_buf_get_name(buf))
        end
    end

    icon = icon or "󰈔"
    icon_hl = icon_hl and ("%#" .. icon_hl .. "#") or "%*"

    if vim.bo[buf].buftype == "" and mini_icons ~= nil then
        M.file_cache[buf] = M.file_cache[buf] or {}
        M.file_cache[buf].icon = { icon = icon, hl = icon_hl }
    end

    return icon_hl .. icon .. hl .. " "
end

local function get_diagnostic_indicator(buf)
    local counts = vim.diagnostic.count(buf)
    if next(counts) == nil then
        return ""
    end

    for _, severity in ipairs({ vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN }) do
        local count = counts[severity]
        if count and count > 0 then
            local info = diag_severity_map[severity]
            return "%#" .. info.hl .. "# " .. info.sign
        end
    end
    return ""
end

local function get_tab_data()
    local tabs = api.nvim_list_tabpages()
    local data = {}
    local name_counts = {}

    for i, tab in ipairs(tabs) do
        local win = api.nvim_tabpage_get_win(tab)
        local buf = api.nvim_win_get_buf(win)
        local path = api.nvim_buf_get_name(buf)
        local name = get_title(buf)

        data[i] = { tab = tab, buf = buf, path = path, name = name }

        name_counts[name] = (name_counts[name] or 0) + 1
    end

    for i, item in ipairs(data) do
        if item.path ~= "" and name_counts[item.name] > 1 then
            local parts = vim.split(item.path, path_sep, { plain = true })
            local res = item.name

            for k = #parts - 1, 1, -1 do
                res = parts[k] .. path_sep .. res
                local collision = false

                for j, other in ipairs(data) do
                    if i ~= j and other.path ~= "" then
                        if string.sub(other.path, -#res) == res then
                            collision = true
                            break
                        end
                    end
                end

                if not collision then
                    item.name = res
                    break
                end
            end
        end
    end

    return data
end

local function build_tab(item, index, is_current)
    local hl = is_current and "%#TabLineSel#" or "%#TabLine#"
    local buf = item.buf

    local icon = get_icon(buf, hl)
    local label = stl_escape(item.name)
    local diag = get_diagnostic_indicator(buf)

    local is_modified = api.nvim_get_option_value("modified", { buf = buf })
    local modified = is_modified and " [+]" or ""

    return table.concat({
        hl,
        "%" .. index .. "T",
        " ",
        icon,
        label,
        modified,
        diag,
        " ",
        "%T",
        "%#TabLineFill#",
    })
end

function M.render()
    local data = get_tab_data()
    local current = api.nvim_get_current_tabpage()
    local chunks = {}

    for i, item in ipairs(data) do
        chunks[#chunks + 1] = build_tab(item, i, item.tab == current)
        if i < #data then
            chunks[#chunks + 1] = "%#TabLine#│"
        end
    end

    chunks[#chunks + 1] = "%#TabLineFill#%="
    if #data > 1 then
        chunks[#chunks + 1] = "%#TabLine#%999X "
    end

    return table.concat(chunks)
end

local function create_autocmds()
    autocmd("DiagnosticChanged", {
        group = group,
        callback = vim.schedule_wrap(function()
            vim.cmd("redrawtabline")
        end),
    })

    autocmd({ "BufEnter", "BufWritePost", "BufDelete", "FileChangedShellPost" }, {
        group = group,
        callback = function(ev)
            clear_buffer_cache(ev.buf)
        end,
    })

    autocmd("OptionSet", {
        group = group,
        pattern = { "filetype" },
        callback = function()
            local buf = api.nvim_get_current_buf()
            clear_buffer_cache(buf)
        end,
    })
end

function M.setup()
    api.nvim_create_augroup(group, { clear = true })
    create_autocmds()

    vim.opt.tabline = "%!v:lua.require('custom.tabline').render()"
end

return M
