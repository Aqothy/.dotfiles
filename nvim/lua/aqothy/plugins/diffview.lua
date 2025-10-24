return {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
        {
            "<leader>gd",
            function()
                Snacks.toggle({
                    name = "Diffview",
                    get = function()
                        return require("diffview.lib").get_current_view() ~= nil
                    end,
                    set = function(state)
                        vim.cmd("Diffview" .. (state and "Open" or "Close"))
                    end,
                }):toggle()
            end,
            desc = "Toggle Diffview",
        },
        { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "Diff File History" },
        { "<leader>gm", "<cmd>DiffviewOpen origin/main<cr>", desc = "Diff Main" },
        { "<leader>pr", "<cmd>DiffviewOpen origin/main...HEAD<cr>", desc = "Diff Merge Base Main" },
    },
    opts = {
        view = {
            merge_tool = {
                layout = "diff3_mixed",
            },
        },
        file_history_panel = {
            win_config = {
                height = 12,
            },
        },
        default_args = {
            DiffviewOpen = { "--imply-local" },
        },
        hooks = {
            diff_buf_win_enter = function(_, winid, ctx)
                vim.wo[winid].signcolumn = "no"
                vim.wo[winid].foldcolumn = "0"
                -- vscode like diff highlight
                if ctx.layout_name:match("^diff2") then
                    if ctx.symbol == "a" then
                        vim.opt_local.winhl = table.concat({
                            "DiffAdd:DiffviewDiffAddAsDelete",
                            "DiffDelete:DiffviewDiffDeleteDim",
                            "DiffChange:DiffviewChangeDelete",
                        }, ",")
                    elseif ctx.symbol == "b" then
                        vim.opt_local.winhl = table.concat({
                            "DiffDelete:DiffviewDiffDeleteDim",
                        }, ",")
                    end
                end
            end,
        },
    },
}
