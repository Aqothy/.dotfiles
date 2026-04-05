local M = {}
local api = vim.api
local fn = vim.fn
local wo = vim.wo

local fillchars = vim.opt.fillchars:get()
local foldclose_char = fillchars.foldclose or ""
local foldopen_char = fillchars.foldopen or ""
local foldsep_char = fillchars.foldsep or " "
local foldexprs = {
    ["v:lua.vim.lsp.foldexpr()"] = vim.lsp.foldexpr,
    ["v:lua.vim.treesitter.foldexpr()"] = vim.treesitter.foldexpr,
}

local function is_fold_start(lnum)
    local level = fn.foldlevel(lnum)
    if level == 0 then
        return false
    end

    if wo.foldmethod == "expr" then
        local foldexpr = foldexprs[wo.foldexpr]
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
        return "%$" .. sign.texthl .. "$" .. text .. "%*"
    end

    return text
end

local function has_signcolumn(win)
    return win.signcolumn ~= "no" and win.signcolumn ~= "number"
end

local function has_foldcolumn(win)
    return win.foldcolumn ~= "0"
end

local function get_sign_kind(details)
    if details.sign_hl_group and vim.startswith(details.sign_hl_group, "GitSigns") then
        return "git"
    end

    return "other"
end

local function get_line_signs(buf, lnum)
    local extmarks = api.nvim_buf_get_extmarks(
        buf,
        -1,
        { lnum - 1, 0 },
        { lnum - 1, -1 },
        { details = true, type = "sign" }
    )
    local git, other
    local other_priority

    for _, mark in ipairs(extmarks) do
        local details = mark[4]

        if details then
            local priority = details.priority or 0
            local kind = get_sign_kind(details)

            if kind == "git" then
                if not git then
                    git = {
                        text = details.sign_text,
                        texthl = details.sign_hl_group,
                    }
                end
            elseif not other or priority > other_priority then
                other = {
                    text = details.sign_text,
                    texthl = details.sign_hl_group,
                }
                other_priority = priority
            end
        end
    end

    return git, other
end

local function render_fold(winid, lnum)
    return api.nvim_win_call(winid, function()
        if fn.foldclosed(lnum) ~= -1 then
            return foldclose_char
        end

        if vim.v.relnum == 0 and is_fold_start(lnum) then
            return foldopen_char
        end

        return foldsep_char
    end)
end

function M.render()
    if vim.v.virtnum ~= 0 then
        return ""
    end
    local winid = vim.g.statusline_winid
    local win = wo[winid]
    local lnum = vim.v.lnum

    local signs = ""
    if has_signcolumn(win) then
        local buf = api.nvim_win_get_buf(winid)
        local git, other = get_line_signs(buf, lnum)
        signs = format_sign(git) .. format_sign(other) .. " "
    end

    local nums = ""
    if win.number or win.relativenumber then
        local number = lnum
        if win.relativenumber then
            number = vim.v.relnum
            if number == 0 and win.number then
                number = lnum
            end
        end

        local text = tostring(number)
        local pad = (" "):rep(math.max(0, win.numberwidth - #text))
        nums = "%=" .. pad .. text .. " "
    end

    local fold = has_foldcolumn(win) and render_fold(winid, lnum) .. " " or ""

    return signs .. nums .. fold
end

return M
