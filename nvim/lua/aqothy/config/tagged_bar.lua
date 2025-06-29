local M = {}
local grapple = require("grapple")
local utils = require("aqothy.config.utils")
local mini_icons = require("mini.icons")

M.tag_cache = nil
M.tab_cache = nil

local group = vim.api.nvim_create_augroup("aqothy/tagged_bar", { clear = true })
local autocmd = vim.api.nvim_create_autocmd

autocmd({ "BufEnter", "WinEnter", "BufWritePost", "TermLeave" }, {
    group = group,
    callback = function()
        M.calculate_tags()
    end,
})

autocmd({ "TabEnter", "TabLeave" }, {
    group = group,
    callback = function()
        M.calculate_tab_info()
    end,
})

autocmd("User", {
    group = group,
    pattern = "GrappleTagToggled",
    callback = function()
        M.calculate_tags()
        vim.cmd("redrawtabline")
    end,
})

function M.calculate_tags()
    local current_file = vim.fn.expand("%:p")
    local tags = grapple.tags()

    if #tags == 0 then
        M.tag_cache = ""
        return
    end

    local tagged_files = {}
    for i, tag in ipairs(tags) do
        local icon, icon_hl = mini_icons.get("file", tag.path)
        local filename = vim.fn.fnamemodify(tag.path, ":t")
        local truncated_name = utils.truncateString(filename, 15)

        if tag.path == current_file then
            filename = "[%#GrappleCurrent#" .. truncated_name .. "%*]"
        else
            filename = truncated_name
        end

        local entry = string.format("%d %%#%s#%s%%* %s", i, icon_hl, icon, filename)
        tagged_files[i] = entry
    end

    M.tag_cache = table.concat(tagged_files, "   ")
end

function M.calculate_tab_info()
    local current_tab = vim.fn.tabpagenr()
    local total_tabs = vim.fn.tabpagenr("$")

    if total_tabs > 1 then
        M.tab_cache = string.format("%%#TabLineSel#[%d/%d]%%* ", current_tab, total_tabs)
    else
        M.tab_cache = ""
    end
end

function M.render()
    if M.tag_cache == nil then
        M.calculate_tags()
    end
    if M.tab_cache == nil then
        M.calculate_tab_info()
    end

    if M.tag_cache == "" then
        -- No tags, only show tab info if multiple tabs exist
        if M.tab_cache ~= "" then
            return "%=" .. M.tab_cache
        else
            return ""
        end
    else
        -- Has tags, show tags centered with tab info on the right
        return "%=" .. M.tag_cache .. "%=" .. M.tab_cache
    end
end

vim.opt.tabline = "%!v:lua.require'aqothy.config.tagged_bar'.render()"
vim.opt.showtabline = 2

return M
