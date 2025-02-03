return {
	"echasnovski/mini.snippets",
	event = "InsertEnter",
	version = false,
	dependencies = "rafamadriz/friendly-snippets",
	enabled = false,
	config = function()
		local mini_snippets = require("mini.snippets")
		local gen_loader = mini_snippets.gen_loader
		local insert = function(snippet)
			-- insert empty tabstop
			return mini_snippets.default_insert(snippet, { empty_tabstop = "", empty_tabstop_final = "" })
		end
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
			expand = {
				-- Resolve raw config snippets at context
				prepare = nil,
				-- Match resolved snippets at cursor position
				match = nil,
				-- Possibly choose among matched snippets
				select = nil,
				-- Insert selected snippet
				insert = insert,
			},
		})
	end,
}
