return {
    "cbochs/grapple.nvim",
    opts = {
        scope = "cwd",
        default_scopes = {
            cwd = { shown = true },
            git = { shown = true },
            git_branch = { shown = true },
            global = { shown = true },
        },
        win_opts = {
            border = "rounded",
        },
    },
    keys = function()
        local keys = {
            { "<leader>m", "<cmd>Grapple toggle<cr>", desc = "Grapple toggle tag" },
            { "<leader>M", "<cmd>Grapple toggle_tags<cr>", desc = "Grapple toggle tags" },
            { "<leader>S", "<cmd>Grapple toggle_scopes<cr>", desc = "Grapple toggle scopes" },
        }

        for i = 1, 5 do
            table.insert(keys, {
                "<leader>" .. i,
                "<cmd>Grapple select index=" .. i .. "<cr>",
                desc = "Grapple select " .. i,
            })
        end
        return keys
    end,
}
