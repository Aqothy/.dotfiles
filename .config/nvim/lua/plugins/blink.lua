return {
    {
        "saghen/blink.cmp",
        event = { "InsertEnter", "CmdLineEnter" },
        version = "*",
        opts = {
            keymap = {
                ["<Up>"] = false,
                ["<Down>"] = false,
            },
            cmdline = {
                enabled = true,
                keymap = { preset = "cmdline", ["<Right>"] = false, ["<Left>"] = false },
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
            sources = {
                providers = {
                    lsp = {
                        timeout_ms = 500,
                    },
                    path = {
                        opts = {
                            show_hidden_files_by_default = true,
                        },
                    },
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
            appearance = {
                kind_icons = require("config.icons").kinds,
            },
        },
    },
    {
        "saghen/blink.indent",
        event = "LazyFile",
        opts = {
            static = {
                char = "▏",
            },
            scope = {
                char = "▏",
            },
        },
    },
}
