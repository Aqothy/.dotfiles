local M = {}

local api = vim.api
local fn = vim.fn

local namespace = "marksigns"
local ns = api.nvim_create_namespace(namespace)
local pending_m = false

M.namespace = namespace

local function is_letter_mark(mark)
    return type(mark.mark) == "string" and mark.mark:match("^'[A-Za-z]$") ~= nil
end

local function decor_mark(bufnr, mark)
    pcall(api.nvim_buf_set_extmark, bufnr, ns, mark.pos[2] - 1, 0, {
        sign_text = mark.mark:sub(2),
        sign_hl_group = "DiagnosticHint",
    })
end

local function decor_marks(bufnr, marks)
    for _, mark in ipairs(marks) do
        if is_letter_mark(mark) and mark.pos[1] == bufnr then
            decor_mark(bufnr, mark)
        end
    end
end

function M.setup()
    api.nvim_set_decoration_provider(ns, {
        on_win = function(_, _, bufnr, top_row, bot_row)
            api.nvim_buf_clear_namespace(bufnr, ns, top_row, bot_row)

            decor_marks(bufnr, fn.getmarklist(bufnr))
            decor_marks(bufnr, fn.getmarklist())
        end,
    })

    vim.on_key(function(key, typed)
        local ch = typed or key

        if pending_m then
            pending_m = false
            if not ch:match("^[A-Za-z]$") then
                return
            end

            local is_upper = ch:match("^[A-Z]$") ~= nil
            vim.schedule(function()
                if is_upper then
                    vim.cmd.redrawstatus({ bang = true })
                else
                    vim.cmd.redrawstatus()
                end
            end)
            return
        end

        pending_m = ch == "m"
    end, ns)
end

return M
