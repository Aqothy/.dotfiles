return {
    "folke/flash.nvim",
    opts = {
        prompt = {
            win_config = {
                border = "none",
            },
        },
        label = {
            uppercase = false,
            min_pattern_length = 1,
            after = false,
            before = { 0, 2 },
        },
        highlight = {
            backdrop = false,
            matches = false,
        },
        jump = {
            autojump = true,
        },
        modes = {
            -- Disable enhanced f and t
            char = {
                enabled = false,
            },
        },
    },
    keys = {
        { "<leader>;", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
        { "<leader>S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
        { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    },
}
