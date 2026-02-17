local M = {}

local function format_sign(sign)
    if not sign or not sign.text then
        return " "
    end
    local text = vim.fn.strcharpart(sign.text, 0, 1)
    if sign.texthl then
        return "%#" .. sign.texthl .. "#" .. text .. "%*"
    end
    return text
end

local function get_line_signs(lnum)
    local extmarks = vim.api.nvim_buf_get_extmarks(
        0,
        -1,
        { lnum - 1, 0 },
        { lnum - 1, -1 },
        { details = true, type = "sign" }
    )
    local git, other

    for _, mark in ipairs(extmarks) do
        local d = mark[4]

        if d then
            local entry = { text = d.sign_text, texthl = d.sign_hl_group, priority = d.priority or 0 }

            if d.sign_hl_group and d.sign_hl_group:find("GitSigns") then
                if not git or entry.priority > git.priority then
                    git = entry
                end
            elseif not other or entry.priority > other.priority then
                other = entry
            end
        end
    end

    return other, git
end

function M.render()
    local other, git = get_line_signs(vim.v.lnum)
    local fold = {
        text = vim.fn.foldclosed(vim.v.lnum) ~= -1 and (vim.opt.fillchars:get().foldclose or "") or " ",
    }
    return format_sign(git) .. format_sign(other) .. " %l " .. format_sign(fold) .. " "
end

function M.setup()
    vim.opt.numberwidth = 7
    vim.opt.statuscolumn = "%!v:lua.require('custom.statuscolumn').render()"
end

return M
