return {
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
}
