return {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdLineEnter" },
    dependencies = {
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-cmdline",
        "xzbdmw/cmp-mini-snippets",
    },
    config = function()
        local user = require("aqothy.config.icons")
        local cmp = require("cmp")
        local compare = cmp.config.compare

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        local cmp_window = {
            border = "rounded",
        }

        cmp.setup({
            window = {
                completion = cmp_window,
                documentation = cmp_window,
            },
            completion = {
                completeopt = "menuone,noinsert",
            },
            snippet = {
                expand = function(args)
                    local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
                    insert({ body = args.body })
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-n>"] = {
                    i = function()
                        if cmp.visible() then
                            cmp.select_next_item(cmp_select)
                        else
                            cmp.complete()
                        end
                    end,
                },
                ["<C-p>"] = {
                    i = function()
                        if cmp.visible() then
                            cmp.select_prev_item(cmp_select)
                        else
                            cmp.complete()
                        end
                    end,
                },
                ["<C-space>"] = {
                    i = function()
                        if cmp.visible() then
                            if cmp.visible_docs() then
                                cmp.close_docs()
                            else
                                cmp.open_docs()
                            end
                        else
                            cmp.complete()
                        end
                    end,
                },
                ["<C-b>"] = cmp.mapping.scroll_docs(-3),
                ["<C-f>"] = cmp.mapping.scroll_docs(3),
            }),

            formatting = {
                fields = { "kind", "abbr", "menu" },
                format = function(_, item)
                    if user.kinds[item.kind] then
                        item.kind = user.kinds[item.kind]
                    end

                    return item
                end,
            },

            view = {
                docs = {
                    auto_open = false,
                },
            },

            performance = {
                debounce = 0,
                throttle = 1,
                confirm_resolve_timeout = 1,
                max_view_entries = 50,
            },

            sorting = {
                priority_weight = 2,
                comparators = {
                    compare.exact,
                    compare.offset,
                    compare.score,
                    compare.recently_used,
                    compare.locality,
                    compare.sort_text,
                    compare.length,
                },
            },

            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "mini.snippets" },
                { name = "path" },
            }, {
                { name = "buffer" },
            }),
        })

        local cmd_map = cmp.mapping.preset.cmdline({
            ["<C-n>"] = {
                c = function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item(cmp_select)
                    else
                        fallback()
                    end
                end,
            },
            ["<C-p>"] = {
                c = function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item(cmp_select)
                    else
                        fallback()
                    end
                end,
            },
        })

        cmp.setup.cmdline({ "/", "?" }, {
            mapping = cmd_map,
            sources = cmp.config.sources({
                { name = "buffer" },
            }),
        })

        cmp.setup.cmdline(":", {
            mapping = cmd_map,
            sources = cmp.config.sources({
                { name = "cmdline" },
                { name = "path" },
            }),
        })
    end,
}
