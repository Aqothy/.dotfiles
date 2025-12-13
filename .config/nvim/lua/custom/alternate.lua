local M = {}

local default = {
    rules = {
        go = {
            { "(.*)%.go$", "%1_test.go" },
            { "(.*)_test%.go$", "%1.go" },
        },
        -- c = {
        --     { "(.*)%.c$", "%1.h" },
        --     { "(.*)%.h$", "%1.c" },
        -- },
    },
    open_cmd = "edit",
}

M.options = {}

local function file_exists(path)
    return vim.uv.fs_stat(path) ~= nil
end

function M.jump(cmd)
    local current_file = vim.fn.expand("%")
    if current_file == "" then
        return vim.notify("Buffer has no file path", vim.log.levels.WARN)
    end

    local ft = vim.bo.filetype

    local rules = M.options.rules[ft]
    if not rules then
        return vim.notify("No alternate rules for filetype: " .. ft, vim.log.levels.INFO)
    end

    local candidates = {}

    for _, rule in ipairs(rules) do
        local pattern, target = rule[1], rule[2]
        if current_file:match(pattern) then
            local alt = current_file:gsub(pattern, target)
            table.insert(candidates, alt)
        end
    end

    if #candidates == 0 then
        return vim.notify("No alternate pattern matched.", vim.log.levels.INFO)
    end

    -- Prefer files that actually exist
    local existing = vim.tbl_filter(file_exists, candidates)

    local is_creation_mode = #existing == 0
    local choices = is_creation_mode and candidates or existing

    local function open(path)
        vim.cmd((cmd or M.options.open_cmd) .. " " .. vim.fn.fnameescape(path))
    end

    if not is_creation_mode and #choices == 1 then
        open(choices[1])
    else
        vim.ui.select(choices, {
            prompt = is_creation_mode and "Create Alternate:" or "Select Alternate:",
            format_item = function(item)
                local name = vim.fn.fnamemodify(item, ":.")
                return is_creation_mode and (name .. " (New)") or name
            end,
        }, function(choice)
            if choice then
                open(choice)
            end
        end)
    end
end

function M.setup(opts)
    M.options = vim.tbl_deep_extend("force", default, opts or {})

    local map = vim.keymap.set
    map("n", "<leader>A", function()
        M.jump()
    end, { desc = "Alternate" })

    vim.api.nvim_create_user_command("As", function()
        M.jump("split")
    end, { desc = "Split Alternate" })
    vim.api.nvim_create_user_command("Av", function()
        M.jump("vsplit")
    end, { desc = "Vsplit Alternate" })
    vim.api.nvim_create_user_command("At", function()
        M.jump("tabedit")
    end, { desc = "Tab Alternate" })
end

return M
