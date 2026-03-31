local M = {}
local api = vim.api
local fn = vim.fn
local wo = vim.wo

local foldclose_char = ""
local foldopen_char = ""
local foldsep_char = " "
local foldexprs = {
    ["v:lua.vim.lsp.foldexpr()"] = vim.lsp.foldexpr,
    ["v:lua.vim.treesitter.foldexpr()"] = vim.treesitter.foldexpr,
}
local statuscolumn_expr = '%!v:lua.require("custom.statuscolumn").render()'

local redraw_group = api.nvim_create_augroup("aqothy_statuscolumn", { clear = true })

local function is_current_line(winid, lnum)
    if wo[winid].relativenumber then
        return vim.v.relnum == 0
    end

    return lnum == api.nvim_win_get_cursor(winid)[1]
end

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
        return "%#" .. sign.texthl .. "#" .. text .. "%*"
    end

    return text
end

local function has_signcolumn(win)
    return win.signcolumn ~= "no" and win.signcolumn ~= "number"
end

local function has_foldcolumn(win)
    return win.foldcolumn ~= "0"
end

local function get_line_signs(buf, lnum)
    local extmarks = api.nvim_buf_get_extmarks(
        buf,
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

local function render_fold(winid, lnum)
    return api.nvim_win_call(winid, function()
        if fn.foldclosed(lnum) ~= -1 then
            return foldclose_char
        end

        if is_current_line(winid, lnum) and is_fold_start(lnum) then
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

    local signs = "%s"
    -- if has_signcolumn(win) then
    --     local buf = api.nvim_win_get_buf(winid)
    --     local git, other = get_line_signs(buf, lnum)
    --     signs = format_sign(git) .. format_sign(other) .. " "
    -- end

    local nums = (win.number or win.relativenumber) and "%l " or ""
    -- if win.number or win.relativenumber then
    --     local number = lnum
    --     if win.relativenumber then
    --         number = vim.v.relnum
    --         if number == 0 and win.number then
    --             number = lnum
    --         end
    --     end
    --
    --     local width = math.max(1, win.numberwidth - 1)
    --     nums = string.format("%" .. width .. "d ", number)
    -- end

    -- local fold = ""
    -- if has_foldcolumn(win) then
    --     local foldwidth = tonumber(win.foldcolumn) or 1
    --     fold = render_fold(winid, lnum) .. string.rep(" ", foldwidth - 1)
    -- end
    local fold = has_foldcolumn(win) and render_fold(winid, lnum) .. " " or ""

    return signs .. nums .. fold
end

function M.setup()
    local fillchars = vim.opt.fillchars:get()
    foldclose_char = fillchars.foldclose or foldclose_char
    foldopen_char = fillchars.foldopen or foldopen_char
    foldsep_char = fillchars.foldsep or foldsep_char

    vim.opt.signcolumn = "yes"
    -- 2 to count for extra space
    vim.opt.foldcolumn = "2"
    vim.opt.statuscolumn = statuscolumn_expr

    -- api.nvim_create_autocmd("OptionSet", {
    --     group = redraw_group,
    --     pattern = { "foldcolumn", "number", "numberwidth", "relativenumber", "signcolumn" },
    --     callback = function()
    --         vim.opt_local.statuscolumn = ""
    --         vim.opt_local.statuscolumn = statuscolumn_expr
    --     end,
    -- })
end

return M
