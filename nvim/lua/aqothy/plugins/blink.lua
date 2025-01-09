local user = require("aqothy.config.user")
return {
	"saghen/blink.cmp",
	version = "*",
	event = { "InsertEnter", "CmdLineEnter" },
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
	opts_extend = { "sources.default", "sources.compat" },
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

			-- optionally disable cmdline completions
			-- cmdline = {},

			providers = {
				-- dont really need priority for now
				snippets = {
					name = "Snippets",
					module = "blink.cmp.sources.snippets",
					score_offset = 1000,
				},
				lsp = {
					name = "LSP",
					module = "blink.cmp.sources.lsp",
					score_offset = 950,
				},
			},
		},
		completion = {
			accept = {
				-- experimental auto-brackets support
				auto_brackets = {
					enabled = true,
				},
			},
			menu = {
				-- nvm cmp type menu
				draw = {
					columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
					treesitter = { "lsp" },
				},
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 300,
			},
			list = {
				selection = {
					auto_insert = false,
				},
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
