return {
	"hrsh7th/nvim-cmp",
	event = { "InsertEnter", "CmdLineEnter" },
	-- enabled = false,
	dependencies = {
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-cmdline",
		"abeldekat/cmp-mini-snippets",
	},
	config = function()
		local user = require("aqothy.config.user")
		local utils = require("aqothy.config.utils")
		local cmp = require("cmp")

		local cmp_select = { behavior = cmp.SelectBehavior.Select }

		local mini_snippets = require("mini.snippets")

		cmp.setup({
			completion = {
				completeopt = "menu,menuone,noinsert",
			},
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
			snippet = {
				expand = function(args)
					local insert = mini_snippets.config.expand.insert or mini_snippets.default_insert
					insert({ body = args.body }) -- Insert at cursor
					cmp.resubscribe({ "TextChangedI", "TextChangedP" })
					require("cmp.config").set_onetime({ sources = {} })
				end,
			},
			experimental = {
				ghost_text = false,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-e>"] = cmp.mapping.abort(),
				["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
				["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
				["<C-space>"] = function()
					if cmp.core.view:visible() then
						if cmp.visible_docs() then
							cmp.close_docs()
						else
							cmp.open_docs()
						end
					else
						cmp.complete()
					end
				end,
				["<C-y>"] = function(fallback)
					if cmp.core.view:visible() then
						cmp.confirm({ select = true })
					else
						fallback()
					end
				end,
				["<C-b>"] = cmp.mapping.scroll_docs(-3),
				["<C-f>"] = cmp.mapping.scroll_docs(3),
			}),
			formatting = {
				fields = { "kind", "abbr", "menu" },
				format = function(entry, item)
					local completion_item = entry.completion_item

					local label_description = completion_item.labelDetails and completion_item.labelDetails.description
						or ""

					local label_detail = completion_item.detail or ""

					-- Use label_detail if label_description is empty
					local menu_text = label_description ~= "" and label_description or label_detail

					item.abbr = utils.truncateString(completion_item.label, 30)
						.. (item.kind == "Snippet" and "~" or "")

					item.kind = user.kinds[item.kind]

					item.menu = utils.truncateString(menu_text, 30)

					return item
				end,
			},

			view = {
				docs = {
					auto_open = false,
				},
			},

			performance = {
				debounce = 30,
				throttle = 15,
				fetching_timeout = 300,
				confirm_resolve_timeout = 35,
				async_budget = 1,
				max_view_entries = 15,
			},

			-- sources for autocompletion with dynamic snippet provider selection
			sources = cmp.config.sources({
				{
					name = "nvim_lsp",
					entry_filter = function(entry)
						return require("cmp.types").lsp.CompletionItemKind[entry:get_kind()] ~= "Text"
					end,
				},
				{ name = "mini_snippets" },
				{ name = "path" },
			}, {
				{ name = "buffer" },
			}),

			sorting = {
				priority_weight = 2,
				comparators = {
					cmp.config.compare.exact,
					cmp.config.compare.offset,
					cmp.config.compare.score,
					cmp.config.compare.scopes,
					cmp.config.compare.recently_used,
					cmp.config.compare.length,
					cmp.config.compare.sort_text,
					cmp.config.compare.locality,
					cmp.config.compare.order,
					cmp.config.compare.kind,
				},
			},
			matching = {
				disallow_fuzzy_matching = false,
				disallow_fullfuzzy_matching = false,
				disallow_partial_fuzzy_matching = false,
				disallow_partial_matching = false,
				disallow_prefix_unmatching = false,
				disallow_symbol_nonprefix_matching = true,
			},
		})

		cmp.setup.cmdline({ "/", "?" }, {
			mapping = cmp.mapping.preset.cmdline({
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
			}),
			sources = {
				{ name = "buffer" },
			},
		})

		cmp.setup.cmdline(":", {
			mapping = cmp.mapping.preset.cmdline({
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
			}),
			sources = cmp.config.sources({
				{ name = "cmdline" },
				{ name = "path" },
			}),
		})
	end,
}
