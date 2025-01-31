local user = require("aqothy.config.user")
return {
	"saghen/blink.cmp",
	version = "*",
	event = { "InsertEnter", "CmdLineEnter" },
	-- enabled = false,
	dependencies = {
		-- enable if there is any cmp sources that you want blink to use from nvim cmp
		-- {
		--     'saghen/blink.compat',
		--     version = '*',
		--     lazy = true,
		--     opts = {
		--         impersonate_nvim_cmp = true,
		--     }
		-- },
	},
	opts_extend = { "sources.default" },
	opts = {
		keymap = {
			preset = "none",
			["<C-y>"] = { "select_and_accept" },
			["<C-b>"] = { "scroll_documentation_up", "fallback" },
			["<C-f>"] = { "scroll_documentation_down", "fallback" },
			["<C-h>"] = { "hide", "fallback" },
			["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-p>"] = { "select_prev", "fallback" },
			["<C-n>"] = { "select_next", "fallback" },
		},

		-- default list of enabled providers defined so that you can extend it
		-- elsewhere in your config, without redefining it, via `opts_extend`
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
			-- adding any nvim-cmp sources here will enable them
			-- with blink.compat, need to uncomment compat in dependencies
			-- compat = {},
			providers = {
				lsp = {
					transform_items = function(_, items)
						-- Remove the "Text" source from lsp autocomplete
						return vim.tbl_filter(function(item)
							return item.kind ~= vim.lsp.protocol.CompletionItemKind.Text
						end, items)
					end,
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
					treesitter = { "lsp" },
					columns = {
						{ "label", "label_description", gap = 1 },
						{ "kind_icon", "kind", gap = 1 },
					},
				},
				border = "rounded",
			},
			list = {
				selection = { auto_insert = false },
				max_items = 10,
			},
			documentation = {
				window = { border = "rounded" },
			},
		},

		snippets = { preset = "luasnip" },

		appearance = {
			-- Sets the fallback highlight groups to nvim-cmp's highlight groups
			-- Useful for when your theme doesn't support blink.cmp
			-- will be removed in a future release
			use_nvim_cmp_as_default = false,
			-- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
			-- Adjusts spacing to ensure icons are aligned
			nerd_font_variant = "mono",
			kind_icons = user.kinds,
		},

		-- experimental signature help support
		signature = {
			enabled = false,
		},
	},
	config = function(_, opts)
		require("blink.cmp").setup(opts)
	end,
}
