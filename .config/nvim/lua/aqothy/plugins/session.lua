return {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
        branch = false,
    },
    -- stylua: ignore
    keys = {
        { "<leader>rl", function() require("persistence").load() end, desc = "Reload Session" },
        { "<leader>ps", function() require("persistence").stop() end, desc = "Persist Stop" },
    },
}
