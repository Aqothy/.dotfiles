return {
	"L3MON4D3/LuaSnip",
	version = "v2.*",
	build = "make install_jsregexp",
	enabled = false,
	event = "InsertEnter",
	opts = {
		keep_roots = true,
		link_roots = true,
		link_children = true,
		delete_check_events = "TextChanged",
		enable_autosnippets = true,
		store_selection_keys = ".",
	},
	dependencies = {
		{
			"rafamadriz/friendly-snippets",
			config = function()
				require("luasnip.loaders.from_vscode").lazy_load()
			end,
		},
	},
	config = function(_, opts)
		local ls = require("luasnip")

		ls.setup(opts)

		-- maybe lua based snippets in the future
		require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })

		--testing if snippets work
		local s = ls.snippet
		local t = ls.text_node
		local i = ls.insert_node
		local c = ls.choice_node

		ls.add_snippets("lua", {
			-- Function snippet
			s("func", {
				t("function "),
				i(1, "function_name"),
				t("("),
				i(2, "args"),
				t(")"),
				t({ "", "    " }),
				i(3, "-- body"),
				t({ "", "end" }),
			}),

			-- Choice node snippet
			s("choice", {
				t("Choose: "),
				c(1, {
					t("Option 1"),
					t("Option 2"),
					t("Option 3"),
				}),
			}),
		})

		vim.keymap.set({ "i" }, "<C-K>", function()
			ls.expand()
		end, { silent = true })
		vim.keymap.set({ "i", "s" }, "<C-L>", function()
			ls.jump(1)
		end, { silent = true })
		vim.keymap.set({ "i", "s" }, "<C-J>", function()
			ls.jump(-1)
		end, { silent = true })

		vim.keymap.set({ "i", "s" }, "<C-E>", function()
			if ls.choice_active() then
				ls.change_choice(1)
			end
		end, { silent = true })
	end,
}
