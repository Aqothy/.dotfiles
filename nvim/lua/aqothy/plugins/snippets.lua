return {
	"L3MON4D3/LuaSnip",
	version = "v2.*",
	build = "make install_jsregexp",
	event = "VeryLazy",
	config = function()
		local ls = require("luasnip")
		-- require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets/" })

		--tester
		local s = ls.snippet -- Define a snippet
		local t = ls.text_node -- Define a text node
		local i = ls.insert_node -- Define an insert node

		ls.add_snippets("lua", {
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
		})
		ls.config.set_config({
			enabled_autosnippets = true,
		})

		vim.keymap.set({ "i" }, "<C-E>", function()
			ls.expand()
		end, { silent = true })
		vim.keymap.set({ "i", "s" }, "<C-L>", function()
			ls.jump(1)
		end, { silent = true })
		vim.keymap.set({ "i", "s" }, "<C-H>", function()
			ls.jump(-1)
		end, { silent = true })

		vim.keymap.set({ "i", "s" }, "<C-S>", function()
			if ls.choice_active() then
				ls.change_choice(1)
			end
		end, { silent = true })
	end,
}
