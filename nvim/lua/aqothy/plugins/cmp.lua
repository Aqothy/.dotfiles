return {
	-- "hrsh7th/nvim-cmp",
	dir = "~/Code/Personal/nvim-cmp",
	event = { "InsertEnter", "CmdLineEnter" },
	enabled = false,
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

		cmp.setup({
			completion = {
				completeopt = "menuone,noinsert",
			},
			snippet = {
				expand = function(args)
					local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
					insert({ body = args.body })
				end,
			},
			experimental = {
				ghost_text = false,
			},
			mapping = cmp.mapping.preset.insert({
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
				["<C-b>"] = cmp.mapping.scroll_docs(-3),
				["<C-f>"] = cmp.mapping.scroll_docs(3),
			}),
			formatting = {
				fields = { "kind", "abbr", "menu" },
				format = function(entry, item)
					local completion_item = entry.completion_item

					local label_detail = ""

					if completion_item.labelDetails then
						if
							completion_item.labelDetails.description
							and completion_item.labelDetails.description ~= ""
						then
							label_detail = completion_item.labelDetails.description
						elseif completion_item.labelDetails.detail and completion_item.labelDetails.detail ~= "" then
							label_detail = completion_item.labelDetails.detail
						end
					end

					if label_detail == "" and completion_item.detail and completion_item.detail ~= "" then
						label_detail = completion_item.detail
					end

					item.abbr = utils.truncateString(completion_item.label, 30)
					item.kind = user.kinds[item.kind]
					item.menu = utils.truncateString(label_detail, 30)

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
				fetching_timeout = 2000,
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
					compare.offset,
					compare.score,
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
