return {
    "folke/flash.nvim",
    opts = {
        -- Disable enhanced f and t
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
        label = {
            uppercase = false,
        },
    },
    keys = {
        {
            "<leader>;",
            mode = { "n", "x", "o" },
            function()
                require("flash").jump()
            end,
            desc = "Flash",
        },
        {
            "<leader>S",
            mode = { "n", "x", "o" },
            function()
                require("flash").treesitter()
            end,
            desc = "Flash Treesitter",
        },
        {
            "r",
            mode = "o",
            function()
                require("flash").remote()
            end,
            desc = "Remote Flash",
        },
    },
}
