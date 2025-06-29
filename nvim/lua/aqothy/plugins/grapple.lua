return {
    "cbochs/grapple.nvim",
    event = "LazyFile",
    opts = {
        scope = "cwd",
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
        command = function(path)
            if vim.api.nvim_buf_get_name(0) ~= path then
                vim.cmd.edit(path)
            end
        end,
        style = "basename",
        win_opts = {
            border = "rounded",
            width = 50,
            row = 10,
        },
    },
    keys = function()
        local keys = {
            {
                "<leader>m",
                function()
                    require("grapple").toggle()
                    vim.api.nvim_exec_autocmds("User", { pattern = "GrappleTagToggled" })
                end,
                desc = "Grapple toggle tag",
            },
            { "<leader>'", "<cmd>Grapple toggle_tags<cr>", desc = "Grapple toggle tags" },
            { "<leader>S", "<cmd>Grapple toggle_scopes<cr>", desc = "Grapple toggle scopes" },
            { "<c-n>", "<cmd>Grapple cycle_tags next<cr>", desc = "Go to next tag" },
            { "<c-p>", "<cmd>Grapple cycle_tags prev<cr>", desc = "Go to previous tag" },
        }

        for i = 1, 4 do
            table.insert(keys, {
                "<leader>" .. i,
                "<cmd>Grapple select index=" .. i .. "<cr>",
                desc = "Grapple select " .. i,
            })
        end
        return keys
    end,
}
