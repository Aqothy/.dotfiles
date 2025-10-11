local M = {}

local api, fn = vim.api, vim.fn
local has_icons, mini_icons = pcall(require, "mini.icons")

local tab_names = {}
local loaded = false
local title_cache = {}
local icon_cache = {}

local autocmd = api.nvim_create_autocmd
local group = api.nvim_create_augroup("AqTabline", { clear = true })

local function clear_buffer_cache(buf)
    title_cache[buf] = nil
    icon_cache[buf] = nil
end

local function load_names()
    if loaded then
        return
    end
    loaded = true

    local ok, decoded = pcall(vim.json.decode, vim.g.AqTabNames or "")
    if not (ok and type(decoded) == "table") then
        return
    end

    tab_names = {}
    for _, tab in ipairs(api.nvim_list_tabpages()) do
        local name = decoded[tostring(api.nvim_tabpage_get_number(tab))]
        if name then
            tab_names[tab] = name
        end
    end
end

local function save_names()
    local snapshot = {}
    for tab, name in pairs(tab_names) do
        if api.nvim_tabpage_is_valid(tab) then
            snapshot[tostring(api.nvim_tabpage_get_number(tab))] = name
        else
            tab_names[tab] = nil
        end
    end
    vim.g.AqTabNames = next(snapshot) and vim.json.encode(snapshot) or nil
end

local function get_title(buf)
    local cached = title_cache[buf]
    if cached then
        return cached
    end

    local name = api.nvim_buf_get_name(buf)
    local value
    if name == "" then
        value = "[No Name]"
    else
        value = fn.pathshorten(fn.fnamemodify(name, ":p:~:t"))
    end

    if vim.bo[buf].buftype == "" then
        title_cache[buf] = value
    end
    return value
end

local function get_icon(buf, hl)
    local cached = icon_cache[buf]

    if cached then
        return "%#" .. cached.hl .. "#" .. cached.icon .. hl .. " "
    end

    local name = api.nvim_buf_get_name(buf)

    local icon, icon_hl

    if has_icons then
        icon, icon_hl = mini_icons.get("file", name)
    end

    icon = icon or "󰈔"
    icon_hl = icon_hl or "%0*"

    if vim.bo[buf].buftype == "" then
        icon_cache[buf] = { icon = icon, hl = icon_hl }
    end

    return "%#" .. icon_hl .. "#" .. icon .. hl .. " "
end

local function build_tab(tab, index, is_current)
    local hl = is_current and "%#TabLineSel#" or "%#TabLine#"
    local win = api.nvim_tabpage_get_win(tab)
    local buf = api.nvim_win_get_buf(win)

    local custom = tab_names[tab]

    local icon = custom and " " or get_icon(buf, hl)
    local label = custom or get_title(buf)

    local modified = api.nvim_get_option_value("modified", { buf = buf }) and " %m " or " "

    local parts = { hl, "%" .. index .. "T", " " }
    parts[#parts + 1] = icon
    parts[#parts + 1] = label
    parts[#parts + 1] = modified
    parts[#parts + 1] = "%T"

    return table.concat(parts)
end

function M.render()
    load_names()

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

    save_names()
    return table.concat(chunks)
end

function M.rename_tab()
    load_names()

    vim.ui.input({ prompt = "Tab name: " }, function(input)
        if not input then
            return
        end
        tab_names[api.nvim_get_current_tabpage()] = input ~= "" and input or nil
        vim.cmd.redrawtabline()
    end)
end

autocmd("SessionLoadPost", {
    group = group,
    callback = function()
        loaded = false
        tab_names = {}
        title_cache = {}
        icon_cache = {}
    end,
})

autocmd({ "BufEnter", "BufWritePost", "BufDelete", "FileChangedShellPost" }, {
    group = group,
    callback = function(ev)
        clear_buffer_cache(ev.buf)
    end,
})

vim.keymap.set("n", "<leader>tr", M.rename_tab, { desc = "Rename tab" })
vim.opt.tabline = "%!v:lua.require('aqothy.config.tabline').render()"

return M
