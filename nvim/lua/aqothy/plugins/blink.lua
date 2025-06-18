return {
    "saghen/blink.cmp",
    -- version = "*",
    event = { "InsertEnter", "CmdLineEnter" },
    enabled = false,
    -- dependencies = {
    --  -- enable if there is any cmp sources that you want blink to use from nvim cmp
    --  {
    --      "saghen/blink.compat",
    --      version = "*",
    --      lazy = true,
    --      opts = {
    --          impersonate_nvim_cmp = true,
    --      },
    --  },
    -- },
    opts_extend = { "sources.default" },
    opts = {
        keymap = {
            preset = "none",
            ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
            ["<C-e>"] = { "hide" },
            ["<C-y>"] = { "select_and_accept" },

            ["<Up>"] = { "select_prev", "fallback" },
            ["<Down>"] = { "select_next", "fallback" },
            ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
            ["<C-n>"] = { "select_next", "fallback_to_mappings" },

            ["<C-b>"] = { "scroll_documentation_up", "fallback" },
            ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        },
        sources = {
            providers = {
                lsp = {
                    fallbacks = { "snippets", "buffer" },
                },
                path = {
                    opts = {
                        show_hidden_files_by_default = true,
                    },
                },
            },
            -- adding any nvim-cmp sources here will enable them
            -- with blink.compat, need to uncomment compat in dependencies
            -- compat = {},
        },
        fuzzy = {
            sorts = {
                -- "exact",
                -- default sorts
                "score",
                "sort_text",
            },
            implementation = "lua",
        },
        cmdline = {
            enabled = true,
            keymap = {
                preset = "none",
                ["<Tab>"] = { "show_and_insert", "select_next" },
                ["<S-Tab>"] = { "show_and_insert", "select_prev" },

                ["<C-space>"] = { "show", "fallback" },

                ["<C-n>"] = { "select_next", "fallback" },
                ["<C-p>"] = { "select_prev", "fallback" },

                ["<C-y>"] = { "select_and_accept" },
                ["<C-e>"] = { "cancel" },
            },
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
                -- experimental auto-brackets support
                auto_brackets = {
                    enabled = false,
                },
            },
            list = {
                selection = { auto_insert = false },
                max_items = 50,
            },
        },

        snippets = {
            preset = "mini_snippets",
        },

        appearance = {
            -- Sets the fallback highlight groups to nvim-cmp's highlight groups
            -- Useful for when your theme doesn't support blink.cmp
            -- will be removed in a future release
            use_nvim_cmp_as_default = false,
            -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
            -- Adjusts spacing to ensure icons are aligned
            nerd_font_variant = "mono",
            kind_icons = require("aqothy.config.user").kinds,
        },

        -- experimental signature help support
        signature = {
            enabled = false,
        },
    },
}
