return {
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
}
