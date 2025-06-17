return {
    "andrewferrier/debugprint.nvim",
    keys = {
        { "<C-g>l", mode = "i", desc = "Insert Variable Log" },
        { "glj", mode = { "n", "x" }, desc = "Log Variable Below" },
        { "gld", desc = "Delete Debug Prints" },
        { "glo", desc = "Operate Log Variable" },
    },
    opts = {
        keymaps = {
            normal = {
                plain_below = "",
                plain_above = "",
                variable_below = "glj",
                variable_above = "",
                variable_below_alwaysprompt = "",
                variable_above_alwaysprompt = "",
                surround_plain = "",
                surround_variable = "",
                surround_variable_alwaysprompt = "",
                textobj_below = "glo",
                textobj_above = "",
                textobj_surround = "",
                toggle_comment_debug_prints = "",
                delete_debug_prints = "gld",
            },
            insert = {
                plain = "",
                variable = "<C-g>l",
            },
            visual = {
                variable_below = "glj",
                variable_above = "",
            },
        },
    },
}
