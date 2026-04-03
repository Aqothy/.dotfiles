local M = {}

M.alternates = {
    ["true"] = "false",
    ["false"] = "true",
    ["True"] = "False",
    ["False"] = "True",
    ["Yes"] = "No",
    ["No"] = "Yes",
    ["||"] = "&&",
    ["&&"] = "||",
    ["or"] = "and",
    ["and"] = "or",
    ["=="] = function(_)
        return vim.bo.filetype == "lua" and "~=" or "!="
    end,
    ["!="] = "==",
    ["==="] = "!==",
    ["!=="] = "===",
    ["~="] = "==",
}

M.alternate_rules = {
    -- snake_case to camelCase
    function(word)
        if word:find("_") then
            return (word:gsub("_(%l)", string.upper))
        end
    end,
    -- camelCase to snake_case
    function(word)
        if word:find("%u") then
            return (word:gsub("(%l)(%u)", "%1_%2"):lower())
        end
    end,
}

local function resolve_alternate(word)
    local alternate = M.alternates[word]

    if alternate ~= nil then
        if type(alternate) == "function" then
            return alternate(word)
        end
        return alternate
    end

    for _, rule in ipairs(M.alternate_rules) do
        local result = rule(word)
        if result then
            return result
        end
    end
end

function M.setup(opts)
    opts = opts or {}

    if opts.alternates then
        M.alternates = vim.tbl_extend("force", M.alternates, opts.alternates)
    end

    if opts.alternate_rules then
        vim.list_extend(M.alternate_rules, opts.alternate_rules)
    end

    vim.keymap.set("n", "<c-a>", M.toggle, { desc = "Toggle alternate word", silent = true })
end

local function get_word_under_cursor()
    vim.cmd("keepjumps normal! viw" .. vim.keycode("<Esc>"))
    local text = vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>"), { type = "v" })
    return text[1]
end

function M.toggle()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local word = get_word_under_cursor()
    local result = resolve_alternate(word)

    if result then
        vim.cmd('normal! "_ciw' .. result)
        vim.api.nvim_win_set_cursor(0, cursor)
    else
        vim.cmd("normal! " .. vim.keycode("<C-a>"))
    end
end

return M
