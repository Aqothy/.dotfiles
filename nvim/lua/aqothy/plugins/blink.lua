return {
    "saghen/blink.cmp",
    version = "v0.*",
    event = "InsertEnter",
    dependencies = {
        "rafamadriz/friendly-snippets",
        "L3MON4D3/LuaSnip",
    },
    opts = {
        keymap = {
            ["<C-u>"] = { "scroll_documentation_up", "fallback" },
            ["<C-d>"] = { "scroll_documentation_down", "fallback" },
            ["<C-h>"] = { "hide", "fallback" },
            ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
            ["<C-p>"] = { "select_prev", "fallback" },
            ["<C-n>"] = { "select_next", "fallback" },
        },

        -- default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, via `opts_extend`
        sources = {
            -- adding any nvim-cmp sources here will enable them
            -- with blink.compat
            completion = {
                enabled_providers = {
                    "snippets",
                    "luasnip",
                    "lsp",
                    "path",
                    "buffer",
                },
            },
            -- optionally disable cmdline completions
            -- cmdline = {},
        },

        completion = {
            accept = {
                -- experimental auto-brackets support
                auto_brackets = {
                    enabled = false,
                },
            },
            menu = {
                draw = {
                    columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
                    treesitter = { "lsp" },
                },
            },
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 200,
            },
            trigger = {
                show_on_insert_trigger_character = false,
            },
        },

        snippets = {
            expand = function(snippet) require('luasnip').lsp_expand(snippet) end,
            active = function(filter)
                if filter and filter.direction then
                    return require('luasnip').jumpable(filter.direction)
                end
                return require('luasnip').in_snippet()
            end,
            jump = function(direction) require('luasnip').jump(direction) end,
        },

        appearance = {
            -- Sets the fallback highlight groups to nvim-cmp's highlight groups
            -- Useful for when your theme doesn't support blink.cmp
            -- will be removed in a future release
            use_nvim_cmp_as_default = true,
            -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
            -- Adjusts spacing to ensure icons are aligned
            nerd_font_variant = "mono",
        },

        -- experimental signature help support
        signature = { enabled = true },
    },
    config = function(_, opts)
        require("blink.cmp").setup(opts)
    end,
}
