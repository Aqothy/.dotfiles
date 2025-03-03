local function truncateString(str, maxLen)
	if vim.fn.strchars(str) > maxLen then
		return vim.fn.strcharpart(str, 0, maxLen - 1) .. "…"
	else
		return str
	end
end

return {
	"hrsh7th/nvim-cmp",
	version = false,
	event = { "InsertEnter", "CmdLineEnter" },
	-- enabled = false,
	dependencies = {
		"hrsh7th/cmp-path", -- source for file system paths
		"saadparwaiz1/cmp_luasnip",
		"hrsh7th/cmp-buffer", -- source for text in buffer
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-cmdline",
	},
	config = function()
		local user = require("aqothy.config.user")
		local cmp = require("cmp")

		local luasnip = require("luasnip")

		local cmp_select = { behavior = cmp.SelectBehavior.Select }

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
					luasnip.lsp_expand(args.body)
				end,
			},
			experimental = {
				ghost_text = false,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-e>"] = cmp.mapping.abort(),
				["<C-p>"] = cmp.mapping.select_prev_item(cmp_select), -- previous suggestion
				["<C-n>"] = cmp.mapping.select_next_item(cmp_select), -- next suggestion
				["<C-space>"] = function()
					if cmp.core.view:visible() then
						if cmp.visible_docs() then
							cmp.close_docs()
						else
							cmp.open_docs()
						end
					else
						cmp.mapping.complete()
					end
				end,
				["<C-y>"] = function(fallback)
					if cmp.core.view:visible() then
						cmp.confirm({ select = true })
					else
						fallback()
					end
				end,
				["<C-u>"] = cmp.mapping.scroll_docs(-3),
				["<C-d>"] = cmp.mapping.scroll_docs(3),
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

					item.menu = truncateString(menu_text, 33)

					item.kind = user.kinds[item.kind or ""]

					item.abbr = truncateString(completion_item.label, 33)

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

			-- sources for autocompletion
			sources = cmp.config.sources({
				{
					name = "nvim_lsp",
					entry_filter = function(entry)
						return require("cmp.types").lsp.CompletionItemKind[entry:get_kind()] ~= "Text"
					end,
				},
				{ name = "luasnip" },
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
				["<C-e>"] = {
					c = function()
						if cmp.visible() then
							cmp.close()
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
				["<C-e>"] = {
					c = function()
						if cmp.visible() then
							cmp.close()
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
