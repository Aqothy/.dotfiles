return {
    "NeogitOrg/neogit",
    dependencies = {
        "nvim-lua/plenary.nvim",  -- required
        "sindrets/diffview.nvim", -- optional - Diff integration
        "ibhagwan/fzf-lua",       -- optional
    },
    cmd = { "Neogit", "DiffviewOpen", "DiffviewClose" },
    keys = {
        {
            "<leader>gs",
            function()
                require("neogit").open({ kind = "split" })
            end,
            desc = "Open Neogit",
        },
        {
            "<leader>gd",
            "<cmd>DiffviewOpen<CR>",
            desc = "Open Diffview",
        },
        {
            "<leader>dc",
            "<cmd>DiffviewClose<CR>",
            desc = "Close Diffview",
        }
    },
    config = function()
        local neogit = require("neogit")
        neogit.setup({})
    end,
}
