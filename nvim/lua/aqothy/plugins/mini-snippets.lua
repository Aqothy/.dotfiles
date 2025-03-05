return {
	"echasnovski/mini.snippets",
	version = false,
	event = "InsertEnter",
	-- enabled = false,
	opts = function()
		local mini_snippets = require("mini.snippets")
		local gen_loader = mini_snippets.gen_loader

		local autocmd = vim.api.nvim_create_autocmd
		local group = vim.api.nvim_create_augroup("stop_session", { clear = true })

		autocmd("User", {
			pattern = "MiniSnippetsSessionStart",
			group = group,
			callback = function()
				autocmd("ModeChanged", {
					pattern = "*:n",
					once = true,
					group = group,
					callback = function()
						while mini_snippets.session.get() do
							mini_snippets.session.stop()
						end
					end,
				})
			end,
		})

		local jsx_patterns = { "javascript.json", "react-es7.json" }
		local tsx_patterns = { "typescript.json", "react-es7.json" }

		-- :=MiniSnippets.default_prepare({}) to see lang
		local lang_patterns = {
			jsx = jsx_patterns,
			tsx = tsx_patterns,
		}

		return {
			snippets = {
				gen_loader.from_lang({ lang_patterns = lang_patterns }),
			},
			mappings = {
				-- Expand snippet at cursor position. Created globally in Insert mode.
				expand = "<C-j>",

				-- Interact with default `expand.insert` session.
				-- Created for the duration of active session(s)
				jump_next = "<C-l>",
				jump_prev = "<C-h>",
				stop = "",
			},
		}
	end,
}
