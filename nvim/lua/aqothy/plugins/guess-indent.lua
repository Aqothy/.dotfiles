return {
    "nmac427/guess-indent.nvim",
    event = "BufReadPre",
    cmd = "GuessIndent",
    keys = {
        { "<leader>gi", "<cmd>GuessIndent<cr>", desc = "Guess Indent" },
    },
    opts = {},
}
