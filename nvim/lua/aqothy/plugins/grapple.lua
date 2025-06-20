return {
    "cbochs/grapple.nvim",
    opts = {
        scope = "cwd_branch",
        default_scopes = {
            lsp = false,
            static = false,
        },
        scopes = {
            {
                name = "cwd_branch",
                desc = "Current working directory and git branch",
                fallback = "cwd",
                cache = {
                    event = { "BufEnter", "FocusGained" },
                    debounce = 1000,
                },
                resolver = function()
                    local git_files = vim.fs.find(".git", {
                        upward = true,
                        stop = vim.loop.os_homedir(),
                    })

                    if #git_files == 0 then
                        return
                    end

                    local root = vim.loop.cwd()

                    local result = vim.fn.system({ "git", "symbolic-ref", "--short", "HEAD" })
                    local branch = vim.trim(string.gsub(result, "\n", ""))

                    local id = string.format("%s:%s", root, branch)
                    local path = root

                    return id, path
                end,
            },
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
            { "<c-s-n>", "<cmd>Grapple cycle_tags next<cr>", desc = "Go to next tag" },
            { "<c-s-p>", "<cmd>Grapple cycle_tags prev<cr>", desc = "Go to previous tag" },
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
