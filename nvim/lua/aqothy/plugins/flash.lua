return {
    "folke/flash.nvim",
    opts = {
        jump = {
            autojump = true,
        },
        search = {
            mode = "search",
        },
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
        { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
        { "gs", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
        { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    },
}
