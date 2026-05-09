return {
    {
        "saghen/blink.cmp",
        event = { "InsertEnter", "CmdLineEnter" },
        version = "*",
        opts = {
            keymap = {
                preset = "none",
                ["<C-y>"] = { "select_and_accept", "fallback" },
                ["<C-s>"] = { "show_signature", "hide_signature", "fallback" },
                ["<C-c>"] = { "hide", "fallback" },
                ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
                ["<CR>"] = { "accept", "fallback" },
                ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
                ["<C-n>"] = { "select_next", "fallback_to_mappings" },
                ["<C-b>"] = { "scroll_documentation_up", "fallback" },
                ["<C-f>"] = { "scroll_documentation_down", "fallback" },
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
                documentation = { auto_show = true },
                trigger = {
                    show_on_insert_on_trigger_character = false,
                },
            },
            snippets = {
                expand = require("custom.snippet-fix").expand,
            },
            sources = {
                per_filetype = {
                    sql = { "snippets", "dadbod_grip", "buffer" },
                },
                providers = {
                    lsp = {
                        timeout_ms = 500,
                    },
                    path = {
                        opts = {
                            show_hidden_files_by_default = true,
                        },
                    },
                    snippets = {
                        should_show_items = function(ctx)
                            return ctx.trigger.initial_kind ~= "trigger_character"
                        end,
                    },
                    dadbod_grip = { name = "Dadbod Grip", module = "dadbod-grip.completion.blink" },
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
            signature = {
                enabled = true,
                trigger = {
                    enabled = false,
                },
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
