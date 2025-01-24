return {
	"echasnovski/mini.surround",
	keys = {
		{ "ys", mode = "n" },
		{ "ds", mode = "n" },
		{ "cs", mode = "n" },
		{ "S", mode = "x" },
	},
	config = function()
		require("mini.surround").setup({
			mappings = {
				add = "ys",
				delete = "ds",
				find = "",
				find_left = "",
				highlight = "",
				replace = "cs",
				update_n_lines = "",
			},
			search_method = "cover_or_next",
		})

		vim.keymap.del("x", "ys")
		vim.keymap.set("x", "S", [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })

		-- Make special mapping for "add surrounding for line"
		vim.keymap.set("n", "yss", "ys_", { remap = true })
	end,
}
