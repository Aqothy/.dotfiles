return {
    {
        "kylechui/nvim-surround",
        keys = {
            { "gz", mode = { "n", "x" }, desc = "Surround Normal And Visual" },
            { "gzz", desc = "Surround Current Line" },
            { "ds", desc = "Delete Surrounding" },
            { "cs", desc = "Change Surrounding" },
        },
        opts = {
            keymaps = {
                insert = false,
                insert_line = false,
                normal = "gz",
                normal_cur = "gzz",
                normal_line = false,
                normal_cur_line = false,
                visual = "gz",
                visual_line = false,
                delete = "ds",
                change = "cs",
                change_line = false,
            },
        },
    },
    {
        "ggandor/leap.nvim",
        keys = {
            { "<leader>;", "<Plug>(leap)", mode = { "n", "x", "o" }, desc = "Leap" },
        },
        opts = {
            preview_filter = function(ch0, ch1, ch2)
                return not (ch1:match("%s") or ch0:match("%a") and ch1:match("%a") and ch2:match("%a"))
            end,
            equivalence_classes = { " \t\r\n", "([{", ")]}", "'\"`" },
            labels = "asdfghjklqwertyuiopzxcvbnm",
            safe_labels = "",
        },
    },
}
