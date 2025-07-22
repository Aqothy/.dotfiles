return {
    "saghen/blink.cmp",
    version = "*",
    event = { "InsertEnter", "CmdLineEnter" },
    opts_extend = { "sources.default" },
    opts = {
        sources = {
            providers = {
                path = {
                    opts = {
                        show_hidden_files_by_default = true,
                    },
                },
            },
        },
        cmdline = {
            enabled = true,
            completion = {
                menu = { auto_show = true },
                list = {
                    selection = {
                        auto_insert = false,
                    },
                },
            },
        },
        term = {
            enabled = false,
        },
        completion = {
            accept = {
                auto_brackets = {
                    enabled = false,
                },
            },
            list = {
                selection = { auto_insert = false },
                max_items = 30,
            },
        },

        appearance = {
            use_nvim_cmp_as_default = false,
            nerd_font_variant = "mono",
            kind_icons = require("aqothy.config.icons").kinds,
        },

        signature = {
            enabled = false,
        },
    },
}
