local M = {}

M.alternates = {
    ["true"] = "false",
    ["false"] = "true",
    ["True"] = "False",
    ["False"] = "True",
    ["TRUE"] = "FALSE",
    ["FALSE"] = "TRUE",
    ["Yes"] = "No",
    ["No"] = "Yes",
    ["YES"] = "NO",
    ["NO"] = "YES",
    ["||"] = "&&",
    ["&&"] = "||",
    ["or"] = "and",
    ["and"] = "or",
    ["=="] = function()
        return vim.bo.filetype == "lua" and "~=" or "!="
    end,
    ["!="] = "==",
    ["==="] = "!==",
    ["!=="] = "===",
    ["~="] = "==",
}

function M.setup(opts)
    if opts and opts.alternates then
        M.alternates = vim.tbl_extend("force", M.alternates, opts.alternates)
    end
end

local function get_word_object()
    local save_cursor = vim.api.nvim_win_get_cursor(0)
    vim.cmd("keepjumps normal! viw")
    local s = vim.api.nvim_buf_get_mark(0, "<")
    local e = vim.api.nvim_buf_get_mark(0, ">")
    vim.api.nvim_win_set_cursor(0, save_cursor)

    if s[1] == 0 or e[1] == 0 then
        return nil
    end

    local lines = vim.api.nvim_buf_get_text(0, s[1] - 1, s[2], e[1] - 1, e[2] + 1, {})
    return lines[1]
end

function M.toggle()
    local word = get_word_object()
    if not word then
        return
    end

    local alternate = M.alternates[word]
    if not alternate then
        return
    end

    local result = type(alternate) == "function" and alternate() or alternate

    vim.cmd('normal! "_ciw' .. result)
end

vim.keymap.set("n", "<leader>i", M.toggle, { desc = "Toggle alternate word" })

return M
