return {
	"saghen/blink.cmp",
	version = "*",
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
	opts = {
		keymap = {
			preset = "default",
		},

		sources = {
			-- Dynamic sources based on treesitter nodes
			default = function()
				local success, node = pcall(vim.treesitter.get_node)
				if
					success
					and node
					and vim.tbl_contains({ "comment", "comment_content", "line_comment", "block_comment" }, node:type())
				then
					return { "buffer" }
				else
					return { "lsp", "path", "snippets", "buffer" }
				end
			end,
			providers = {
				path = {
					opts = {
						show_hidden_files_by_default = true,
					},
				},
				buffer = {
					opts = {
						-- Only current buf
						get_bufnrs = function()
							return { vim.api.nvim_get_current_buf() }
						end,
					},
				},
			},
			-- adding any nvim-cmp sources here will enable them
			-- with blink.compat, need to uncomment compat in dependencies
			-- compat = {},
		},
		fuzzy = {
			sorts = {
				function(a, b)
					if (a.client_name == nil or b.client_name == nil) or (a.client_name == b.client_name) then
						return
					end
					return b.client_name == "emmet_language_server"
				end,
				"exact",
				-- default sorts
				"score",
				"sort_text",
			},
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
				border = "rounded",
			},
			list = {
				selection = { auto_insert = false },
				max_items = 30,
			},
			documentation = {
				window = { border = "rounded" },
			},
		},

		snippets = {
			preset = "mini_snippets",
		},

		appearance = {
			-- Sets the fallback highlight groups to nvim-cmp's highlight groups
			-- Useful for when your theme doesn't support blink.cmp
			-- will be removed in a future release
			use_nvim_cmp_as_default = false,
			-- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
			-- Adjusts spacing to ensure icons are aligned
			nerd_font_variant = "mono",
			kind_icons = require("aqothy.config.user").kinds,
		},

		-- experimental signature help support
		signature = {
			enabled = false,
		},
	},
}
