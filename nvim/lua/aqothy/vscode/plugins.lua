return {
    {
        "echasnovski/mini.surround",
        keys = {
            { "gz", desc = "Add Surrounding", mode = { "n", "x" } },
            { "ds", desc = "Delete Surrounding" },
            { "cs", desc = "Replace Surrounding" },
        },
        opts = {
            mappings = {
                add = "gz",
                delete = "ds",
                find = "",
                find_left = "",
                highlight = "",
                replace = "cs",
                update_n_lines = "",
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
}
