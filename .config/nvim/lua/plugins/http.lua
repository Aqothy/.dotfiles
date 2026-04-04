return {
    "mistweaverco/kulala.nvim",
    ft = "http",
    keys = {
        { "]]", "<cmd>lua require('kulala').jump_next()<cr>", desc = "Jump to next request", ft = "http" },
        { "[[", "<cmd>lua require('kulala').jump_prev()<cr>", desc = "Jump to previous request", ft = "http" },
        { "<localleader>rr", "<cmd>lua require('kulala').replay()<cr>", desc = "Replay the last request", ft = "http" },
        { "<localleader>rs", "<cmd>lua require('kulala').run()<cr>", desc = "Send the request", ft = "http" },
        { "<localleader>ra", "<cmd>lua require('kulala').run_all()<cr>", desc = "Run all requests", ft = "http" },
        {
            "<localleader>rt",
            "<cmd>lua require('kulala').toggle_view()<cr>",
            desc = "Toggle headers/body",
            ft = "http",
        },
    },
    opts = {},
}
