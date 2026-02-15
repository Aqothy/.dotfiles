return {
    "mistweaverco/kulala.nvim",
    ft = "http",
    keys = {
        { "<localleader>rb", "<cmd>lua require('kulala').scratchpad()<cr>", desc = "Open scratchpad" },
        { "<localleader>rc", "<cmd>lua require('kulala').copy()<cr>", desc = "Copy as cURL", ft = "http" },
        { "<localleader>rC", "<cmd>lua require('kulala').from_curl()<cr>", desc = "Paste from curl", ft = "http" },
        { "<localleader>re", "<cmd>lua require('kulala').set_selected_env()<cr>", desc = "Set environment", ft = "http" },
        { "<localleader>ri", "<cmd>lua require('kulala').inspect()<cr>", desc = "Inspect current request", ft = "http" },
        { "]]", "<cmd>lua require('kulala').jump_next()<cr>", desc = "Jump to next request", ft = "http" },
        { "[[", "<cmd>lua require('kulala').jump_prev()<cr>", desc = "Jump to previous request", ft = "http" },
        { "<localleader>rq", "<cmd>lua require('kulala').close()<cr>", desc = "Close window", ft = "http" },
        { "<localleader>rr", "<cmd>lua require('kulala').replay()<cr>", desc = "Replay the last request" },
        { "<localleader>rs", "<cmd>lua require('kulala').run()<cr>", desc = "Send the request", ft = "http" },
        { "<localleader>rS", "<cmd>lua require('kulala').show_stats()<cr>", desc = "Show stats", ft = "http" },
        { "<localleader>rt", "<cmd>lua require('kulala').toggle_view()<cr>", desc = "Toggle headers/body", ft = "http" },
    },
    opts = {},
}
