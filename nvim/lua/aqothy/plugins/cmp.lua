return {
    -- "hrsh7th/nvim-cmp",
    'saghen/blink.cmp',
    version = 'v0.*',
    lazy = false,
    -- event = "InsertEnter",
    dependencies = {
        -- "hrsh7th/cmp-path",             -- source for file system paths
        "L3MON4D3/LuaSnip",
        -- "saadparwaiz1/cmp_luasnip",     -- for autocompletion
        "rafamadriz/friendly-snippets", -- useful snippets
        -- "hrsh7th/cmp-buffer",           -- source for text in buffer
    },
    opts_extend = { "sources.default" },

    config = function()
        -- local cmp = require("cmp")
        --
        -- local luasnip = require("luasnip")
        --
        -- -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
        -- require("luasnip.loaders.from_vscode").lazy_load()
        -- local cmp_select = { behavior = cmp.SelectBehavior.Select }
        --
        -- cmp.setup({
        --     snippet = { -- configure how nvim-cmp interacts with snippet engine
        --         expand = function(args)
        --             luasnip.lsp_expand(args.body)
        --         end,
        --     },
        --     mapping = cmp.mapping.preset.insert({
        --         ["<C-k>"] = cmp.mapping.select_prev_item(cmp_select), -- previous suggestion
        --         ["<C-j>"] = cmp.mapping.select_next_item(cmp_select), -- next suggestion
        --         ["<C-Space>"] = cmp.mapping.complete(),               -- show completion suggestions
        --         ["<C-enter>"] = cmp.mapping.confirm({ select = true }),
        --     }),
        --     -- sources for autocompletion
        --     sources = cmp.config.sources({
        --         { name = "nvim_lsp" },
        --         { name = "luasnip" }, -- snippets
        --         { name = "buffer" },  -- text within current buffer
        --         { name = "path" },    -- file system paths
        --     }),
        -- })

        require('blink.cmp').setup({
            -- 'default' for mappings similar to built-in completion
            -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
            -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
            -- see the "default configuration" section below for full documentation on how to define
            -- your own keymap.
            keymap = {
                ["<C-y>"] = { "select_and_accept", "fallback" },
                ["<C-u>"] = { "scroll_documentation_up", "fallback" },
                ["<C-d>"] = { "scroll_documentation_down", "fallback" },
                ["<C-h>"] = { "hide", "fallback" },
                ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
                ["<C-k>"] = { "select_prev", "fallback" },
                ["<C-j>"] = { "select_next", "fallback" },
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

            completion = {
                accept = {
                    -- experimental auto-brackets support
                    auto_brackets = {
                        enabled = false,
                    },
                },
                menu = {
                    draw = {
                        treesitter = { "lsp" },
                    },
                },
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 200,
                },
            },

            appearance = {
                -- Sets the fallback highlight groups to nvim-cmp's highlight groups
                -- Useful for when your theme doesn't support blink.cmp
                -- will be removed in a future release
                use_nvim_cmp_as_default = true,
                -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = 'normal'
            },

            -- default list of enabled providers defined so that you can extend it
            -- elsewhere in your config, without redefining it, via `opts_extend`
            sources = {
                default = { 'lsp', 'path', 'snippets', 'luasnip', 'buffer' },
                -- optionally disable cmdline completions
                -- cmdline = {},
            },

            -- experimental signature help support
            -- signature = { enabled = true }

        })
    end,
}
