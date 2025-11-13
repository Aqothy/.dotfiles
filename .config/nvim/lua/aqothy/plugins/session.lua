return {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
        branch = false,
    },
    -- stylua: ignore
    keys = {
        { "<leader>rl", function() require("persistence").load() end, desc = "Restore Session" },
        { "<leader>ds", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
    },
}
