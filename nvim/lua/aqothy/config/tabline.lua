local M = {}

local mini_icons = require("mini.icons")

local function get_filename(bufnr)
    local file = vim.fn.bufname(bufnr)

    if file == "" then
        return "[No Name]"
    else
        return vim.fn.fnamemodify(file, ":t")
    end
end

local function build_tab(index)
    local is_current = vim.fn.tabpagenr() == index
    local buflist = vim.fn.tabpagebuflist(index)
    local winnr = vim.fn.tabpagewinnr(index)
    local bufnr = buflist[winnr]

    local filename = get_filename(bufnr)
    local icon, icon_hl = mini_icons.get("file", filename)

    local hl = is_current and "%#TabLineSel#" or "%#TabLine#"

    -- The index is needed for %T to make tabs clickable
    local label = hl .. "%" .. index .. "T "
    label = label .. "%#" .. icon_hl .. "#" .. icon .. " " .. hl .. filename
    label = label .. " %T"

    return label
end

function M.render()
    local tab_count = vim.fn.tabpagenr("$")
    local tabline = ""

    for i = 1, tab_count do
        tabline = tabline .. build_tab(i)
        if i < tab_count then
            tabline = tabline .. "%#TabLine#│"
        end
    end

    tabline = tabline .. "%#TabLineFill#%="

    if tab_count > 1 then
        tabline = tabline .. "%#TabLine#%999X "
    end

    return tabline
end

vim.opt.tabline = "%!v:lua.require('aqothy.config.tabline').render()"

return M
