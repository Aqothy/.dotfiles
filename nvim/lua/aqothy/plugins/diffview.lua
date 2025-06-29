return {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
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
        { "<leader>gF", "<cmd>DiffviewFileHistory<cr>", desc = "File History" },
        { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "File History Current File" },
        { "<leader>gm", "<cmd>DiffviewOpen main..HEAD<cr>", desc = "Diff Main" },
        { "<leader>gM", "<cmd>DiffviewOpen main...HEAD<cr>", desc = "Diff Merge Base Main" },
    },
    opts = function()
        return {
            view = {
                default = {
                    winbar_info = true,
                },
                merge_tool = {
                    layout = "diff3_mixed",
                },
            },
            file_panel = {
                win_config = {
                    width = 30,
                },
            },
            file_history_panel = {
                win_config = {
                    height = 12,
                },
            },
        }
    end,
}
