return {
    "saghen/blink.cmp",
    event = { "InsertEnter", "CmdLineEnter" },
    opts_extend = { "sources.default" },
    opts = {
        keymap = {
            preset = "enter",
        },
        cmdline = {
            completion = {
                menu = { auto_show = true },
                list = {
                    selection = {
                        auto_insert = false,
                    },
                },
            },
        },
        completion = {
            list = {
                max_items = 30,
                selection = { auto_insert = false },
            },
        },
        fuzzy = {
            implementation = "lua",
            sorts = {
                "exact",
                "score",
                "sort_text",
            },
        },
        signature = {
            enabled = true,
            trigger = {
                enabled = false,
            },
        },
    },
}
