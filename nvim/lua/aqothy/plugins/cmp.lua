local function truncateString(str, maxLen)
	if #str > maxLen then
		return str:sub(1, maxLen - 1) .. "…"
	else
		return str
	end
end

return {
	"iguanacucumber/magazine.nvim",
	event = { "InsertEnter", "CmdLineEnter" },
	version = false,
	-- enabled = false,
	dependencies = {
		"hrsh7th/cmp-path", -- source for file system paths
		"abeldekat/cmp-mini-snippets",
		"hrsh7th/cmp-buffer", -- source for text in buffer
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-cmdline",
	},
	config = function()
		local user = require("aqothy.config.user")
		local cmp = require("cmp")

		-- local luasnip = require("luasnip")

		local cmp_select = { behavior = cmp.SelectBehavior.Select }

		cmp.setup({
			completion = {
				completeopt = "menu,menuone,noinsert",
			},
			window = {
				completion = {
					border = "rounded",
				},
				documentation = {
					border = "rounded",
				},
			},
			snippet = {
				expand = function(args) -- mini.snippets expands snippets from lsp...
					local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
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
				["<C-y>"] = cmp.mapping.confirm({ select = true }),
				["<C-f>"] = cmp.mapping.scroll_docs(-4),
				["<C-b>"] = cmp.mapping.scroll_docs(4),
			}),
			formatting = {
				expandable_indicator = false,
				fields = { "kind", "abbr", "menu" },
				format = function(_, item)
					item.menu = item.kind
					item.menu_hl_group = "CmpItemKind" .. (item.kind or "")
					item.kind = user.kinds[item.kind]
					item.abbr = truncateString(item.abbr, 50)

					return item
				end,
			},

			view = {
				docs = {
					auto_open = false,
				},
			},

			performance = {
				debounce = 5,
				throttle = 6,
				fetching_timeout = 10000,
				confirm_resolve_timeout = 6,
				async_budget = 1,
				max_view_entries = 10,
			},

			-- sources for autocompletion
			sources = cmp.config.sources({
				{
					name = "nvim_lsp",
					-- entry_filter = function(entry)
					-- 	return require("cmp.types").lsp.CompletionItemKind[entry:get_kind()] ~= "Text"
					-- end,
				},
				{ name = "mini_snippets" },
			}, {
				{ name = "buffer" },
				{ name = "path" },
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
			mapping = cmp.mapping.preset.cmdline(),
			sources = {
				{ name = "buffer" },
			},
		})

		cmp.setup.cmdline(":", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = cmp.config.sources({
				{ name = "path" },
			}, {
				{ name = "cmdline" },
			}),
		})
	end,
}
