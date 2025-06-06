return {
    "kylechui/nvim-surround",
    keys = {
        { "<C-g>s", mode = "i", desc = "Add Surround In Insert Mode" },
        { "<C-g>S", mode = "i", desc = "Add Surround On New Lines In Insert Mode" },
        { "gz", mode = { "n", "v" }, desc = "Surround Normal And Visual" },
        { "gzz", mode = "n", desc = "Surround Current Line" },
        { "gZ", mode = "n", desc = "Surround On New Lines" },
        { "gZZ", mode = "n", desc = "Surround Current Line On New Lines" },
        { "Z", mode = "v", desc = "Surround Visual Selection On New Lines" },
        { "ds", mode = "n", desc = "Delete Surrounding" },
        { "cs", mode = "n", desc = "Change Surrounding" },
        { "cS", mode = "n", desc = "Change Surrounding On New Lines" },
    },
    opts = {
        keymaps = {
            insert = "<C-g>s",
            insert_line = "<C-g>S",
            normal = "gz",
            normal_cur = "gzz",
            normal_line = "gZ",
            normal_cur_line = "gZZ",
            visual = "gz",
            visual_line = "Z",
            delete = "ds",
            change = "cs",
            change_line = "cS",
        },
    },
}
