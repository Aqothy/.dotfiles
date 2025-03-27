return {
	"hrsh7th/nvim-cmp",
	event = { "InsertEnter", "CmdLineEnter" },
	-- enabled = false,
	dependencies = {
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-cmdline",
		"xzbdmw/cmp-mini-snippets",
	},
	config = function()
		local user = require("aqothy.config.user")
		local utils = require("aqothy.config.utils")
		local cmp = require("cmp")
		local compare = cmp.config.compare

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
					local label_details = completion_item.labelDetails

					item.abbr = utils.truncateString(completion_item.label, 30)
					item.kind = user.kinds[item.kind]
					item.menu = utils.truncateString(
						(label_details and label_details.description) or completion_item.detail or "",
						15
					)

					return item
				end,
			},

			view = {
				docs = {
					auto_open = false,
				},
			},

			performance = {
				debounce = 6,
				throttle = 3,
				max_view_entries = 30,
			},

			-- sources for autocompletion with dynamic snippet provider selection
			sources = cmp.config.sources({
				{
					name = "nvim_lsp",
					entry_filter = function(entry)
						return require("cmp.types").lsp.CompletionItemKind[entry:get_kind()] ~= "Text"
					end,
				},
				{
					name = "mini.snippets",
					option = {
						only_show_in_line_start = true,
					},
				},
				{ name = "path" },
			}, {
				{
					name = "buffer",
					option = {
						indexing_interval = 1000,
						get_bufnrs = function()
							local buf = vim.api.nvim_get_current_buf()
							local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
							if byte_size > 1024 * 1024 then -- 1 Megabyte max
								return {}
							end
							return { buf }
						end,
					},
				},
			}),

			sorting = {
				priority_weight = 2,
				comparators = {
					compare.exact,
					compare.score,
					compare.offset,
					compare.scopes,
					compare.recently_used,
					compare.length,
					compare.sort_text,
					compare.locality,
					compare.order,
					compare.kind,
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
			}),
			sources = cmp.config.sources({
				{ name = "buffer" },
			}),
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
