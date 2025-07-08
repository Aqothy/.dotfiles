return {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    -- stylua: ignore
    keys = {
        { "<leader>sl", function() require("persistence").load() end, desc = "Session Load" },
        { "<leader>ss", function() require("persistence").select() end, desc = "Select Session" },
        { "<leader>qs", function() require("persistence").stop() end, desc = "Quit Session" },
    },
}
