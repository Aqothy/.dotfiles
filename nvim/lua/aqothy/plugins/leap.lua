return {
    "ggandor/leap.nvim",
    keys = {
        { "<leader>;", "<Plug>(leap)", mode = { "n", "x", "o" }, desc = "Leap" },
        {
            "gs",
            function()
                require("leap.treesitter").select({ opts = { safe_labels = "asdfghjklqwertyuiopzxcvbnm" } })
            end,
            mode = { "n", "x", "o" },
        },
    },
    opts = {
        preview_filter = function(ch0, ch1, ch2)
            return not (ch1:match("%s") or ch0:match("%a") and ch1:match("%a") and ch2:match("%a"))
        end,
        equivalence_classes = { " \t\r\n", "([{", ")]}", "'\"`" },
        labels = "asdfghjklqwertyuiopzxcvbnm",
        safe_labels = "",
    },
}
