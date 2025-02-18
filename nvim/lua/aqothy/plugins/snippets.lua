return {
	"L3MON4D3/LuaSnip",
	version = "v2.*",
	-- build = "make install_jsregexp",
	lazy = true,
	opts = {
		keep_roots = true,
		link_roots = true,
		link_children = true,
		delete_check_events = "TextChanged",
		enable_autosnippets = true,
		store_selection_keys = ",",
	},
	keys = {
		{
			"<C-l>",
			function()
				require("luasnip").jump(1)
			end,
			mode = { "i", "s" },
			silent = true,
		},
		{
			"<C-j>",
			function()
				require("luasnip").jump(-1)
			end,
			mode = { "i", "s" },
			silent = true,
		},
		{
			"<C-g>",
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
			",",
			mode = "v",
		},
	},
	config = function(_, opts)
		require("luasnip").setup(opts)

		-- maybe lua based snippets in the future
		require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
	end,
}
