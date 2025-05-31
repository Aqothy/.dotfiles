return {
    "otavioschwanck/arrow.nvim",
    keys = {
        { "'", desc = "Arrow" },
        { "m", desc = "Mark Buffer Loc" },
    },
    opts = {
        separate_by_branch = true,
        buffer_leader_key = "m",
        show_icons = true,
        leader_key = "'", -- Recommended to be a single key
        hide_handbook = true,
        hide_buffer_handbook = true,
        window = {
            border = "rounded",
        },
        per_buffer_config = {
            lines = 6,
        },
    },
}
