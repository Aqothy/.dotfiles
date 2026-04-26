return {
    {
        "saghen/blink.cmp",
        event = { "InsertEnter", "CmdLineEnter" },
        version = "*",
        opts = {
            keymap = {
                preset = "enter",
                ["<C-y>"] = { "select_and_accept", "fallback" },
                ["<C-s>"] = { "show_signature", "hide_signature", "fallback" },
                ["<C-c>"] = { "hide", "fallback" },
                ["<C-e>"] = false,
                ["<C-k>"] = false,
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
                documentation = { auto_show = true },
                trigger = {
                    show_on_insert_on_trigger_character = false,
                },
            },
            snippets = { preset = "mini_snippets" },
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
                sorts = function()
                    if vim.api.nvim_get_mode().mode == "c" then
                        return { "score", "sort_text" }
                    end

                    return {
                        "exact",
                        function(a, b)
                            if math.abs(a.score - b.score) > 3 then
                                return
                            end

                            return require("blink.cmp.fuzzy.sort").sort_text(a, b)
                        end,
                        "score",
                        "label",
                        "kind",
                    }
                end,
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
