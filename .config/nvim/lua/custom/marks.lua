local M = {}

local api = vim.api
local fn = vim.fn

local ns = api.nvim_create_namespace("marksigns")
local pending_m = false

local function is_letter_mark(mark)
    return type(mark.mark) == "string" and mark.mark:match("^'[A-Za-z]$") ~= nil
end

local function decor_mark(bufnr, mark)
    pcall(api.nvim_buf_set_extmark, bufnr, ns, mark.pos[2] - 1, 0, {
        priority = 15,
        sign_text = mark.mark:sub(2),
        sign_hl_group = "DiagnosticHint",
    })
end

local function decor_marks(bufnr, marks, top_row, bot_row)
    for _, mark in ipairs(marks) do
        if
            is_letter_mark(mark)
            and mark.pos[1] == bufnr
            and mark.pos[2] - 1 >= top_row
            and mark.pos[2] - 1 < bot_row
        then
            decor_mark(bufnr, mark)
        end
    end
end

function M.setup()
    api.nvim_set_decoration_provider(ns, {
        on_win = function(_, _, bufnr, top_row, bot_row)
            api.nvim_buf_clear_namespace(bufnr, ns, top_row, bot_row)
            decor_marks(bufnr, fn.getmarklist(bufnr), top_row, bot_row)
            decor_marks(bufnr, fn.getmarklist(), top_row, bot_row)
        end,
    })

    vim.on_key(function(key, typed)
        local ch = typed or key

        if pending_m then
            pending_m = false
            if not ch:match("^[A-Za-z]$") then
                return
            end

            vim.schedule(function()
                vim.cmd.redrawstatus()
            end)
            return
        end

        pending_m = ch == "m"
    end, ns)
end

return M
