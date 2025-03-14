return {
	"echasnovski/mini.snippets",
	event = "InsertEnter",
	-- enabled = false,
	opts = function()
		local mini_snippets = require("mini.snippets")
		local gen_loader = mini_snippets.gen_loader

		local has_cmp, cmp = pcall(require, "nvim-cmp")
		local has_blink, blink = pcall(require, "blink.cmp")

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

		local autocmd = vim.api.nvim_create_autocmd
		local group = vim.api.nvim_create_augroup("stop_session", { clear = true })

		-- Stop session on esc
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
			expand = {
				select = function(snippets, insert)
					-- Close completion window on snippet select - vim.ui.select
					local select = expand_select_override or mini_snippets.default_select
					select(snippets, insert)
				end,
				insert = my_insert,
			},
		}
	end,
}
