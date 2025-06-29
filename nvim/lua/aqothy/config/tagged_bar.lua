local M = {}
local grapple = require("grapple")
local utils = require("aqothy.config.utils")
local mini_icons = require("mini.icons")
M.tab_cache = nil
local group = vim.api.nvim_create_augroup("aqothy/tagged_bar", { clear = true })
local autocmd = vim.api.nvim_create_autocmd

autocmd({ "BufEnter", "WinEnter", "BufWritePost", "TermLeave", "TabEnter", "TabLeave" }, {
    group = group,
    callback = function()
        M.calculate_tags()
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

    local current_tab = vim.fn.tabpagenr()
    local total_tabs = vim.fn.tabpagenr("$")

    local tab_info = ""
    if total_tabs > 1 then
        tab_info = string.format("[%d/%d] ", current_tab, total_tabs)
    end

    if #tags == 0 then
        if total_tabs > 1 then
            M.tab_cache = "%=" .. tab_info
        else
            M.tab_cache = ""
        end
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

    local grapple_content = table.concat(tagged_files, "   ")
    M.tab_cache = "%=" .. grapple_content .. "%=" .. tab_info
end

function M.render()
    if not M.tab_cache then
        M.calculate_tags()
    end
    return M.tab_cache
end

vim.opt.tabline = "%!v:lua.require'aqothy.config.tagged_bar'.render()"
vim.opt.showtabline = 2

return M
