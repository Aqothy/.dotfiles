return {
	"echasnovski/mini.snippets",
	event = "InsertEnter",
	version = false,
	dependencies = "rafamadriz/friendly-snippets",
	config = function()
		local gen_loader = require("mini.snippets").gen_loader
		require("mini.snippets").setup({
			snippets = {
				-- gen_loader.from_file("~/.config/nvim/snippets/global.json"),
				gen_loader.from_lang(),
			},

			mappings = {
				-- Expand snippet at cursor position. Created globally in Insert mode.
				expand = "<C-k>",

				-- Interact with default `expand.insert` session.
				-- Created for the duration of active session(s)
				jump_next = "<C-l>",
				jump_prev = "<C-j>",
				stop = "<C-h>",
			},
		})
	end,
}
