return {
    "kylechui/nvim-surround",
    keys = {
        { "ys", desc = "Surround Normal" },
        { "S", mode = "x", desc = "Surround Visual" },
        { "yss", desc = "Surround Current Line" },
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
