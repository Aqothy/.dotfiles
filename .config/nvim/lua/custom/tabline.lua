local M = {}

local api = vim.api

local function stl_escape(str)
    if not str or str == "" then
        return str
    end
    return str:gsub("%%", "%%%%")
end

local path_sep = package.config:sub(1, 1)

local function get_buf_info(buf)
    local bt = vim.bo[buf].buftype
    local path = api.nvim_buf_get_name(buf)
    local title
    if path == "" then
        title = bt ~= "" and bt or "[No Name]"
    else
        title = vim.fs.basename(path)
    end

    return { title = title, path = path }
end

local function matching_tail_parts(a, b)
    local n = 0

    while a[#a - n] and a[#a - n] == b[#b - n] do
        n = n + 1
    end

    return n
end

local function get_tab_data()
    local tabs = api.nvim_list_tabpages()
    local data = {}
    local name_counts = {}

    for i, tab in ipairs(tabs) do
        local win = api.nvim_tabpage_get_win(tab)
        local buf = api.nvim_win_get_buf(win)
        local info = get_buf_info(buf)
        local parts = info.path == "" and nil or vim.split(info.path, path_sep, { plain = true })

        data[i] = { tab = tab, buf = buf, path = info.path, parts = parts, title = info.title, name = info.title }

        name_counts[info.title] = (name_counts[info.title] or 0) + 1
    end

    for i, item in ipairs(data) do
        if item.path ~= "" and name_counts[item.title] > 1 then
            local needed = 1

            for j, other in ipairs(data) do
                if i ~= j and other.path ~= "" and other.path ~= item.path and item.title == other.title then
                    needed = math.max(needed, matching_tail_parts(item.parts, other.parts) + 1)
                end
            end

            if needed > 1 then
                item.name = table.concat(item.parts, path_sep, #item.parts - needed + 1)
            end
        end
    end

    return data
end

local function build_tab(item, index, is_current)
    local hl = is_current and "%#TabLineSel#" or "%#TabLine#"
    local buf = item.buf

    local label = stl_escape(item.name)

    local is_modified = api.nvim_get_option_value("modified", { buf = buf })
    local modified = is_modified and " ●" or ""

    return table.concat({
        hl,
        "%" .. index .. "T",
        " ",
        label,
        modified,
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
    end

    return table.concat(chunks)
end

function M.setup()
    vim.opt.tabline = "%!v:lua.require('custom.tabline').render()"
end

return M
