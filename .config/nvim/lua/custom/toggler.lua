local M = {}

local default_alternates = {
    ["true"] = "false",
    ["True"] = "False",
    ["Yes"] = "No",
    ["||"] = "&&",
    ["or"] = "and",
    ["=="] = function(_)
        return vim.bo.filetype == "lua" and "~=" or "!="
    end,
    ["!="] = "==",
    ["==="] = "!==",
    ["~="] = "==",
}

local function build_lookup(alternates, auto_inverse)
    local lookup = vim.tbl_extend("force", {}, alternates)

    if auto_inverse then
        for word, alternate in pairs(alternates) do
            if type(alternate) == "string" and lookup[alternate] == nil then
                lookup[alternate] = word
            end
        end
    end

    return lookup
end

local default_alternate_rules = {
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

local function build_rules(extra_rules)
    local rules = vim.list_extend({}, default_alternate_rules)
    if extra_rules then
        vim.list_extend(rules, extra_rules)
    end
    return rules
end

local lookup = build_lookup(default_alternates, true)
local alternate_rules = build_rules()

local function resolve_alternate(word)
    local alternate = lookup[word]

    if alternate ~= nil then
        if type(alternate) == "function" then
            return alternate(word)
        end
        return alternate
    end

    for _, rule in ipairs(alternate_rules) do
        local result = rule(word)
        if result then
            return result
        end
    end
end

function M.setup(opts)
    opts = opts or {}
    local auto_inverse = opts.auto_inverse ~= false
    local alternates = vim.tbl_extend("force", {}, default_alternates)

    if opts.alternates then
        alternates = vim.tbl_extend("force", alternates, opts.alternates)
    end

    lookup = build_lookup(alternates, auto_inverse)
    alternate_rules = build_rules(opts.alternate_rules)

    vim.keymap.set("n", "<c-a>", M.toggle, { desc = "Toggle alternate word", silent = true })
end

local function get_word_under_cursor()
    local cursor = vim.api.nvim_win_get_cursor(0)
    vim.cmd("keepjumps normal! viw" .. vim.keycode("<Esc>"))
    local text = vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>"))
    vim.api.nvim_win_set_cursor(0, cursor)
    return text[1]
end

function M.toggle()
    local count = vim.v.count
    local cursor = vim.api.nvim_win_get_cursor(0)
    local word = get_word_under_cursor()
    local result = resolve_alternate(word)

    if result then
        vim.cmd('normal! "_ciw' .. result)
        vim.api.nvim_win_set_cursor(0, cursor)
    else
        local prefix = count > 0 and tostring(count) or ""
        vim.cmd("normal! " .. prefix .. vim.keycode("<C-a>"))
    end
end

return M
