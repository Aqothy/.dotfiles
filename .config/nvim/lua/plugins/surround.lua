return {
    "kylechui/nvim-surround",
    keys = {
        { "ys", desc = "Surround Normal" },
        { "yss", desc = "Surround Current Line" },
        { "S", mode = "x", desc = "Surround Visual" },
        { "ds", desc = "Delete Surrounding" },
        { "cs", desc = "Change Surrounding" },
    },
    opts = {
        keymaps = {
            insert = false,
            insert_line = false,
            normal = "ys",
            normal_cur = "yss",
            normal_line = false,
            normal_cur_line = false,
            visual = "S",
            visual_line = false,
            delete = "ds",
            change = "cs",
            change_line = false,
        },
    },
}
