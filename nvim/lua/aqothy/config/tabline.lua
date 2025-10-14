local M = {}

local api = vim.api
local fn = vim.fn
local has_icons, mini_icons = pcall(require, "mini.icons")

local tab_names = {}
local loaded = false
local title_cache = {}
local icon_cache = {}
local pick_mode = false
local pick_labels = {}
local pick_targets = {}

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
    local buftype = vim.bo[buf].buftype
    local value
    if name == "" then
        value = buftype ~= "" and buftype or "No Name"
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

local function label_seed_from_name(name)
    if not name or name == "" then
        return "a"
    end

    local char = name:sub(1, 1):lower()
    if char:match("%l") then
        return char
    end

    local fallback = name:match("%a")
    return fallback and fallback:lower() or "a"
end

local function next_letter(letter)
    local byte = letter:byte()
    byte = byte and byte + 1 or string.byte("a")
    if byte > string.byte("z") then
        byte = string.byte("a")
    end
    return string.char(byte)
end

local function compute_pick_labels(tabs)
    local assigned = {}
    local labels_for_tab = {}
    local targets = {}
    local primary = {}
    local remaining_primary = {}

    for _, tab in ipairs(tabs) do
        local win = api.nvim_tabpage_get_win(tab)
        local buf = api.nvim_win_get_buf(win)
        local custom = tab_names[tab]
        local name = custom or get_title(buf)
        local seed = label_seed_from_name(name)

        primary[tab] = seed
        remaining_primary[seed] = (remaining_primary[seed] or 0) + 1
    end

    for _, tab in ipairs(tabs) do
        local seed = primary[tab]
        remaining_primary[seed] = remaining_primary[seed] - 1

        local label = seed
        local attempts = 0
        while attempts < 26 do
            local reserved_elsewhere = remaining_primary[label] and remaining_primary[label] > 0
            if not assigned[label] and (not reserved_elsewhere or label == seed) then
                break
            end
            label = next_letter(label)
            attempts = attempts + 1
        end

        assigned[label] = tab
        labels_for_tab[tab] = label
        targets[label] = tab
    end

    return labels_for_tab, targets
end

local function build_tab(tab, index, is_current)
    local hl = is_current and "%#TabLineSel#" or "%#TabLine#"
    local win = api.nvim_tabpage_get_win(tab)
    local buf = api.nvim_win_get_buf(win)

    local custom = tab_names[tab]
    local icon = custom and " " or get_icon(buf, hl)
    local label = custom or get_title(buf)

    local modified = api.nvim_get_option_value("modified", { buf = buf }) and " ● " or " "

    local parts = { hl, "%" .. index .. "T", " " }
    if pick_mode then
        local pick = pick_labels[tab]
        if pick then
            parts[#parts + 1] = "%#ModeMsg#" .. pick .. hl .. " "
        end
    end
    parts[#parts + 1] = icon
    parts[#parts + 1] = label
    parts[#parts + 1] = modified
    parts[#parts + 1] = "%T"

    return table.concat(parts)
end

function M.pick_tab()
    local tabs = api.nvim_list_tabpages()

    pick_mode = true
    pick_labels, pick_targets = compute_pick_labels(tabs)
    vim.cmd.redrawtabline()

    local ok, char = pcall(fn.getcharstr)
    local tab
    if ok and char then
        char = char:lower()
        tab = pick_targets[char]
    end

    pick_mode = false
    pick_labels = {}
    pick_targets = {}

    if tab and api.nvim_tabpage_is_valid(tab) then
        api.nvim_set_current_tabpage(tab)
    end
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
vim.keymap.set("n", "<leader>k", M.pick_tab, { desc = "Pick tab" })

vim.opt.tabline = "%!v:lua.require('aqothy.config.tabline').render()"

return M
