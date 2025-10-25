local M = {}

local api = vim.api
local has_icons, mini_icons = pcall(require, "mini.icons")

local title_cache = {}
local icon_cache = {}

local autocmd = api.nvim_create_autocmd
local group = api.nvim_create_augroup("AqTabline", { clear = true })

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

    if has_icons then
        icon, icon_hl = mini_icons.get("file", name)
    end

    icon = icon or "󰈔"
    icon_hl = icon_hl and ("%#" .. icon_hl .. "#") or "%0*"

    if vim.bo[buf].buftype == "" then
        icon_cache[buf] = { icon = icon, hl = icon_hl }
    end

    return icon_hl .. icon .. hl .. " "
end

local function build_tab(tab, index, is_current)
    local hl = is_current and "%#TabLineSel#" or "%#TabLine#"
    local win = api.nvim_tabpage_get_win(tab)
    local buf = api.nvim_win_get_buf(win)

    local icon = get_icon(buf, hl)
    local label = get_title(buf)

    local modified = api.nvim_get_option_value("modified", { buf = buf }) and " %m " or " "

    local parts = { hl, "%" .. index .. "T", " " }
    parts[#parts + 1] = icon
    parts[#parts + 1] = label
    parts[#parts + 1] = modified
    parts[#parts + 1] = "%T"

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
