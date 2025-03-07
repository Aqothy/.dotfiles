local user = require("aqothy.config.user")

return {
	"saghen/blink.cmp",
	build = "cargo build --release",
	event = { "InsertEnter", "CmdLineEnter" },
	enabled = false,
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
	opts = function()
		local has_luasnip, _ = pcall(require, "luasnip")
		local has_mini, _ = pcall(require, "mini.snippets")

		return {
			keymap = {
				preset = "none",
				["<C-y>"] = { "select_and_accept" },
				["<C-b>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },
				["<C-e>"] = { "hide", "fallback" },
				["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
				["<C-p>"] = { "select_prev", "fallback" },
				["<C-n>"] = { "select_next", "fallback" },
			},

			sources = {
				-- Dynamic sources based on treesitter nodes
				default = function(ctx)
					local success, node = pcall(vim.treesitter.get_node)
					if
						success
						and node
						and vim.tbl_contains(
							{ "comment", "comment_content", "line_comment", "block_comment" },
							node:type()
						)
					then
						return { "buffer" }
					else
						return { "lsp", "path", "snippets", "buffer" }
					end
				end,

				-- adding any nvim-cmp sources here will enable them
				-- with blink.compat, need to uncomment compat in dependencies
				-- compat = {},
			},
			cmdline = {
				enabled = true,
				completion = {
					menu = { auto_show = true },
					list = {
						selection = {
							auto_insert = false,
						},
					},
				},
			},
			term = {
				enabled = true,
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
					border = "rounded",
				},
				list = {
					selection = { auto_insert = false },
					max_items = 15,
				},
				documentation = {
					window = { border = "rounded" },
				},
			},

			snippets = {
				preset = has_luasnip and "luasnip" or has_mini and "mini_snippets" or "default",
			},

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
		}
	end,
}
