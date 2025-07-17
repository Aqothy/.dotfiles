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
        { "<leader>gF", "<cmd>DiffviewFileHistory<cr>", desc = "File History" },
        { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "File History Current File" },
        { "<leader>gm", "<cmd>DiffviewOpen main<cr>", desc = "Diff Main" },
        { "<leader>gM", "<cmd>DiffviewOpen main...HEAD<cr>", desc = "Diff Merge Base Main" },
    },
    opts = {},
}
