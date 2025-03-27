return {
	"echasnovski/mini.snippets",
	event = "InsertEnter",
	-- enabled = false,
	opts = function()
		local mini_snippets = require("mini.snippets")
		local gen_loader = mini_snippets.gen_loader

		local has_cmp, cmp = pcall(require, "nvim-cmp")
		local has_blink, blink = pcall(require, "blink.cmp")
		local has_copilot, copilot = pcall(require, "copilot.suggestion")

		local expand_select_override = nil

		if has_cmp then
			expand_select_override = function(snippets, insert)
				if cmp.visible() then
					cmp.close()
				end
				mini_snippets.default_select(snippets, insert)
			end
		elseif has_blink then
			expand_select_override = function(snippets, insert)
				blink.cancel()
				mini_snippets.default_select(snippets, insert)
			end
		end

		local my_insert = function(snippet)
			-- Empty tabstop chars
			return mini_snippets.default_insert(snippet, { empty_tabstop = "", empty_tabstop_final = "" })
		end

		local my_m = function(snippets)
			return mini_snippets.default_match(snippets, { pattern_fuzzy = "%w*" })
		end

		local autocmd = vim.api.nvim_create_autocmd
		local group = vim.api.nvim_create_augroup("stop_session", { clear = true })

		-- Stop session on esc
		local make_stop = function()
			local au_opts = { pattern = "*:n", once = true, group = group }
			au_opts.callback = function()
				while mini_snippets.session.get() do
					mini_snippets.session.stop()
				end
			end
			autocmd("ModeChanged", au_opts)
		end
		local opts = { pattern = "MiniSnippetsSessionStart", callback = make_stop, group = group }
		autocmd("User", opts)

		local jsx_patterns = { "javascript.json", "react-es7.json" }
		local tsx_patterns = { "typescript.json", "react-es7.json" }

		-- :=MiniSnippets.default_prepare({}) to see lang or just press <C-j> in insert mode
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

			expand = {
				select = function(snippets, insert)
					-- Close completion window and clear copilot ghost text on snippet select - vim.ui.select
					local select = expand_select_override or mini_snippets.default_select
					if has_copilot and copilot.is_visible() then
						copilot.dismiss()
					end
					select(snippets, insert)
				end,
				insert = my_insert,
				match = my_m,
			},
		}
	end,
}
