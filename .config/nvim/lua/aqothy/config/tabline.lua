local M = {}

local api = vim.api
local has_mini_icons, mini_icons = pcall(require, "mini.icons")
local has_icons, icons = pcall(require, "aqothy.config.icons")

local title_cache = {}
local icon_cache = {}

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
    title_cache[buf] = nil
    icon_cache[buf] = nil
end

local function get_title(buf)
    local cached = title_cache[buf]
    if cached then
        return cached
    end

    local name = api.nvim_buf_get_name(buf)
    local buftype = vim.bo[buf].buftype
    local value
    if name == "" then
        value = buftype ~= "" and buftype or "[No Name]"
    else
        local basename = vim.fs.basename(name)
        value = basename == "" and name or basename
    end

    -- Cache only normal buffers
    if buftype == "" then
        title_cache[buf] = value
    end
    return value
end

local function get_icon(buf, hl)
    local cached = icon_cache[buf]
    if cached then
        return cached.hl .. cached.icon .. hl .. " "
    end

    local name = api.nvim_buf_get_name(buf)
    local icon, icon_hl

    if has_mini_icons then
        icon, icon_hl = mini_icons.get("file", name)
    end

    icon = icon or "󰈔"
    icon_hl = icon_hl and ("%#" .. icon_hl .. "#") or "%0*"

    if vim.bo[buf].buftype == "" then
        icon_cache[buf] = { icon = icon, hl = icon_hl }
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
            return "%#" .. info.hl .. "#" .. info.sign
        end
    end
    return ""
end

local function build_tab(tab, index, is_current)
    local hl = is_current and "%#TabLineSel#" or "%#TabLine#"
    local win = api.nvim_tabpage_get_win(tab)
    local buf = api.nvim_win_get_buf(win)

    local icon = get_icon(buf, hl)
    local label = get_title(buf)
    local diag = get_diagnostic_indicator(buf)

    local modified = api.nvim_get_option_value("modified", { buf = buf }) and " %m " or " "

    local parts = {
        hl,
        "%" .. index .. "T", -- Clickable region start
        " ",
        icon,
        label,
        modified,
        diag,
        " ",
        "%T", -- Clickable region end
        "%#TabLineFill#", -- Reset to fill color between tabs
    }

    return table.concat(parts)
end

function M.render()
    local tabs = api.nvim_list_tabpages()
    local current = api.nvim_get_current_tabpage()
    local chunks = {}

    for i, tab in ipairs(tabs) do
        chunks[#chunks + 1] = build_tab(tab, i, tab == current)
        if i < #tabs then
            chunks[#chunks + 1] = "%#TabLine#│"
        end
    end

    chunks[#chunks + 1] = "%#TabLineFill#%="
    if #tabs > 1 then
        chunks[#chunks + 1] = "%#TabLine#%999X "
    end

    return table.concat(chunks)
end

autocmd({ "BufEnter", "BufWritePost", "BufDelete", "FileChangedShellPost" }, {
    group = group,
    callback = function(ev)
        clear_buffer_cache(ev.buf)
    end,
})

vim.opt.tabline = "%!v:lua.require('aqothy.config.tabline').render()"

return M
