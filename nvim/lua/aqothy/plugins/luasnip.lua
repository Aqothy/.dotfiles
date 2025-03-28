return {
	"L3MON4D3/LuaSnip",
	event = "InsertEnter",
	enabled = false,
	opts = {
		keep_roots = true,
		link_roots = true,
		link_children = true,
		delete_check_events = "TextChanged",
		enable_autosnippets = true,
		store_selection_keys = "<C-x>",
	},
	keys = {
		{
			"<C-j>",
			function()
				require("luasnip").expand()
			end,
			mode = { "i" },
			silent = true,
		},
		{
			"<C-l>",
			function()
				require("luasnip").jump(1)
			end,
			mode = { "i", "s" },
			silent = true,
		},
		{
			"<C-h>",
			function()
				require("luasnip").jump(-1)
			end,
			mode = { "i", "s" },
			silent = true,
		},
		{
			"<C-m>",
			function()
				if require("luasnip").choice_active() then
					require("luasnip").change_choice(1)
				end
			end,
			mode = { "i", "s" },
			silent = true,
		},
		{
			"<C-r>y",
			function()
				require("luasnip.extras.otf").on_the_fly("s")
			end,
			desc = "Insert on-the-fly snippet",
			mode = "i",
		},
		{
			"<C-x>",
			mode = "v",
		},
	},
	config = function(_, opts)
		require("luasnip").setup(opts)

		-- maybe lua based snippets in the future
		require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
	end,
}
