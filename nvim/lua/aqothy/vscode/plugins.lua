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
    {
        "echasnovski/mini.splitjoin",
        keys = {
            { "<leader>j", mode = { "n", "x" }, desc = "SplitJoin" },
        },
        opts = function()
            local gen_hook = require("mini.splitjoin").gen_hook
            local curly = { brackets = { "%b{}" } }

            -- Add trailing comma when splitting inside curly brackets
            local add_comma_curly = gen_hook.add_trailing_separator(curly)

            -- Delete trailing comma when joining inside curly brackets
            local del_comma_curly = gen_hook.del_trailing_separator(curly)

            -- Pad curly brackets with single space after join
            local pad_curly = gen_hook.pad_brackets(curly)
            return {
                mappings = {
                    toggle = "<leader>j",
                },
                split = { hooks_post = { add_comma_curly } },
                join = { hooks_post = { del_comma_curly, pad_curly } },
            }
        end,
    },
    {
        "andrewferrier/debugprint.nvim",
        keys = {
            { "glj", mode = { "n", "x" }, desc = "Log Variable Below" },
            { "<c-g>l", mode = { "i" }, desc = "Log Variable Below In Insert Mode" },
            { "gll", desc = "Log Plain Below" },
            { "gld", desc = "Delete Debug Prints" },
            { "glo", desc = "Operate Log Variable" },
        },
        opts = {
            keymaps = {
                normal = {
                    plain_below = "gll",
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
                    variable = "<c-g>l",
                },
                visual = {
                    variable_below = "glj",
                    variable_above = "",
                },
            },
        },
    },
}
