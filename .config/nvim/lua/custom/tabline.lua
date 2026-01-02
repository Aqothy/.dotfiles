local M = {}

local api = vim.api
local has_mini_icons, mini_icons = pcall(require, "mini.icons")
local has_icons, icons = pcall(require, "config.icons")

M.file_cache = {}

local autocmd = api.nvim_create_autocmd
local group = api.nvim_create_augroup("AqTabline", { clear = true })

local diag_signs = has_icons and icons.diagnostics or { Error = "●", Warn = "●", Info = "●", Hint = "●" }

local diag_severity_map = {
    [vim.diagnostic.severity.ERROR] = { sign = diag_signs.Error, hl = "DiagnosticError" },
    [vim.diagnostic.severity.WARN] = { sign = diag_signs.Warn, hl = "DiagnosticWarn" },
    [vim.diagnostic.severity.INFO] = { sign = diag_signs.Info, hl = "DiagnosticInfo" },
    [vim.diagnostic.severity.HINT] = { sign = diag_signs.Hint, hl = "DiagnosticHint" },
}

autocmd("DiagnosticChanged", {
    group = group,
    callback = function()
        vim.schedule(function()
            vim.cmd("redrawtabline")
        end)
    end,
})

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

    if has_mini_icons then
        icon, icon_hl = mini_icons.get("filetype", ft)
    end

    icon = icon or "󰈔"
    icon_hl = icon_hl and ("%#" .. icon_hl .. "#") or "%0*"

    if vim.bo[buf].buftype == "" then
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
            local parts = vim.split(item.path, "/")
            local res = item.name

            for k = #parts - 1, 1, -1 do
                res = parts[k] .. "/" .. res
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
    local label = item.name
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

autocmd({ "BufFilePost", "BufWritePost", "BufDelete", "FileChangedShellPost" }, {
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

vim.opt.tabline = "%!v:lua.require('custom.tabline').render()"

return M
