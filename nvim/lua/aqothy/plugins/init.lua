return {
    "nvim-lua/plenary.nvim", -- Lua functions that many plugins use
    "nvim-tree/nvim-web-devicons",
    {
        "alanfortlink/blackjack.nvim",
        cmd = "BlackJackNewGame", -- Lazy load when this command is executed
        opts = {
            scores_path = nil,    -- Disable score tracking by setting it to nil
        },
    },
}
