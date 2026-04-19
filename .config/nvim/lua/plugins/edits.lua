return {
    {
        "altermo/ultimate-autopair.nvim",
        event = "InsertEnter",
        opts = {
            cmap = false,
            fastwarp = { nocursormove = false },
            bs = { delete_from_end = false },
            extensions = {
                suround = false,
                utf8 = false,
            },
        },
    },
    {
        "windwp/nvim-ts-autotag",
        ft = {
            "html",
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
        },
        opts = {},
    },
    {
        "Wansmer/treesj",
        keys = {
            { "<leader>J", "<cmd>TSJToggle<cr>", desc = "Join Toggle" },
        },
        opts = { use_default_keymaps = false, max_join_length = 150 },
    },
    {
        "nmac427/guess-indent.nvim",
        cmd = "GuessIndent",
        event = "BufReadPre",
        opts = {},
    },
    {
        "chrisgrieser/nvim-spider",
        keys = {
            {
                "e",
                "<cmd>lua require('spider').motion('e')<CR>",
                mode = { "n", "x", "o" },
                desc = "End of subword",
            },
            {
                "b",
                "<cmd>lua require('spider').motion('b')<CR>",
                mode = { "n", "x", "o" },
                desc = "Beginning of subword",
            },
        },
    },
}
