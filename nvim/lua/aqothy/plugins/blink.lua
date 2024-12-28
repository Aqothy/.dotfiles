return {
    "saghen/blink.cmp",
    version = '*',
    event = "InsertEnter",
    dependencies = {
        "rafamadriz/friendly-snippets",
        "L3MON4D3/LuaSnip",
        -- {
        --     'saghen/blink.compat',
        --     version = '*',
        --     lazy = true,
        --     opts = {
        --         impersonate_nvim_cmp = true,
        --     }
        -- },
    },
    opts_extend = { "sources.default", "sources.compat" },
    opts = {
        keymap = {
            preset = 'none',
            ['<C-y>'] = { 'select_and_accept' },
            ["<C-b>"] = { "scroll_documentation_up", "fallback" },
            ["<C-f>"] = { "scroll_documentation_down", "fallback" },
            ["<C-h>"] = { "hide", 'fallback' },
            ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
            ["<C-p>"] = { "select_prev", "fallback" },
            ["<C-n>"] = { "select_next", "fallback" },
        },

        -- default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, via `opts_extend`
        sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer', 'luasnip' },
            -- adding any nvim-cmp sources here will enable them
            -- with blink.compat
            -- compat = {},

            -- optionally disable cmdline completions
            -- cmdline = {},
            providers = {
                lsp = {
                    name = 'LSP',
                    module = 'blink.cmp.sources.lsp',
                    score_offset = 1000,
                },

                snippets = {
                    name = 'Snippets',
                    module = 'blink.cmp.sources.snippets',
                    score_offset = 950,
                },
                luasnip = {
                    name = 'Luasnip',
                    module = 'blink.cmp.sources.luasnip',
                    score_offset = 900,
                },
            }
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
                auto_show_delay_ms = 0,
            },
            trigger = {
                show_on_insert_on_trigger_character = true,
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
        signature = { enabled = false },
    },
    config = function(_, opts)
        require("blink.cmp").setup(opts)
    end,
}
