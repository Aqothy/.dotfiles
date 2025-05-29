return {
    "otavioschwanck/arrow.nvim",
    keys = { { "'", desc = "Arrow" }, { "m", desc = "Mark Buffer Loc" } },
    opts = {
        separate_by_branch = true,
        save_key = "git_root",
        buffer_leader_key = "m",
        show_icons = true,
        leader_key = "'", -- Recommended to be a single key
        hide_handbook = true,
        window = {
            border = "rounded",
        },
    },
}
