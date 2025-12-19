return {
    {
        "altermo/ultimate-autopair.nvim",
        event = "InsertEnter",
        opts = {
            cmap = false,
            extensions = {
                suround = false,
                utf8 = false,
                filetype = { nft = { "snacks_picker_input" } },
                alpha = { after = true },
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
}
