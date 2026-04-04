return {
    "folke/flash.nvim",
    opts = {
        label = {
            uppercase = false,
            after = false,
            before = true,
            rainbow = {
                enabled = true,
                shade = 3,
            },
        },
        highlight = {
            matches = false,
        },
        modes = {
            char = {
                enabled = false,
            },
        },
        prompt = {
            win_config = {
                border = "none",
            },
        },
    },
    -- stylua: ignore
    keys = {
        { "<leader>;", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
        { "S", mode = { "n", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
        { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    },
}
