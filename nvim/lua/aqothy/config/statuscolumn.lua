local M = {}

local fcs = vim.opt.fillchars:get()

function M.get_fold(lnum)
    if vim.fn.foldlevel(lnum) <= vim.fn.foldlevel(lnum - 1) then
        return " "
    end
    if vim.fn.foldclosed(lnum) ~= -1 then
        return fcs.foldclose
    else
        return " "
    end
end

function M.render()
    return "%s%l " .. M.get_fold(vim.v.lnum) .. " "
end

return M
