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
        { "<leader>gf", "<cmd>DiffviewFileHistory<cr>", desc = "File History" },
        { "<leader>gm", "<cmd>DiffviewOpen remotes/origin/main..HEAD<cr>", desc = "Diff Main" },
    },
    opts = function()
        return {
            view = {
                merge_tool = {
                    layout = "diff1_plain",
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
