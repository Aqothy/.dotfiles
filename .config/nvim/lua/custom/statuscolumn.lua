local M = {}
local api = vim.api
local fn = vim.fn

local foldclose_char = ""
local foldopen_char = ""
local foldexprs = {
    ["v:lua.vim.lsp.foldexpr()"] = vim.lsp.foldexpr,
    ["v:lua.vim.treesitter.foldexpr()"] = vim.treesitter.foldexpr,
}

local function is_current_line(lnum)
    if vim.wo.relativenumber then
        return vim.v.relnum == 0
    end

    return lnum == api.nvim_win_get_cursor(0)[1]
end

local function is_fold_start(lnum)
    local level = fn.foldlevel(lnum)
    if level == 0 then
        return false
    end

    if vim.wo.foldmethod == "expr" then
        local foldexpr = foldexprs[vim.wo.foldexpr]
        if foldexpr then
            local value = foldexpr(lnum)
            if type(value) == "string" then
                return value:sub(1, 1) == ">"
            end
        end
    end

    return level > fn.foldlevel(lnum - 1)
end

local function format_sign(sign)
    if not sign or not sign.text then
        return " "
    end

    local text = fn.strcharpart(sign.text, 0, 1)
    if sign.texthl then
        return "%#" .. sign.texthl .. "#" .. text .. "%*"
    end

    return text
end

local function get_line_signs(lnum)
    local extmarks = api.nvim_buf_get_extmarks(
        0,
        -1,
        { lnum - 1, 0 },
        { lnum - 1, -1 },
        { details = true, type = "sign" }
    )
    local git_text, git_texthl
    local other_text, other_texthl
    local git_priority, other_priority

    for _, mark in ipairs(extmarks) do
        local details = mark[4]

        if details then
            local hl = details.sign_hl_group or ""
            local priority = details.priority or 0

            if hl:find("GitSigns", 1, true) then
                if not git_text or priority > git_priority then
                    git_text = details.sign_text
                    git_texthl = details.sign_hl_group
                    git_priority = priority
                end
            elseif not other_text or priority > other_priority then
                other_text = details.sign_text
                other_texthl = details.sign_hl_group
                other_priority = priority
            end
        end
    end

    local git = git_text and { text = git_text, texthl = git_texthl } or nil
    local other = other_text and { text = other_text, texthl = other_texthl } or nil

    return git, other
end

local function render_fold(lnum)
    if fn.foldclosed(lnum) ~= -1 then
        return foldclose_char
    end

    if is_current_line(lnum) and is_fold_start(lnum) then
        return foldopen_char
    end

    return " "
end

function M.render()
    local lnum = vim.v.lnum
    local git, other = get_line_signs(lnum)
    return format_sign(git) .. format_sign(other) .. " %l " .. render_fold(lnum) .. " "
end

function M.setup()
    local fillchars = vim.opt.fillchars:get()
    foldclose_char = fillchars.foldclose or foldclose_char
    foldopen_char = fillchars.foldopen or foldopen_char

    vim.opt.numberwidth = 7
    vim.opt.statuscolumn = "%!v:lua.require('custom.statuscolumn').render()"
end

return M
