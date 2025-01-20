return {
	"lewis6991/gitsigns.nvim",
	event = { "LazyFile" },
	opts = {
		signs = {
			add = { text = " ▎" },
			change = { text = " ▎" },
			delete = { text = " " },
			topdelete = { text = " " },
			changedelete = { text = " ▎" },
			untracked = { text = " ┆" },
		},
		signs_staged = {
			add = { text = " ▎" },
			change = { text = " ▎" },
			delete = { text = " " },
			topdelete = { text = " " },
			changedelete = { text = " ▎" },
		},
		attach_to_untracked = true,
		on_attach = function(bufnr)
			local gs = package.loaded.gitsigns

			-- Mappings.
			---@param lhs string
			---@param rhs function
			---@param desc string
			local function nmap(lhs, rhs, desc)
				vim.keymap.set("n", lhs, rhs, { desc = desc, buffer = bufnr })
			end
			nmap("[h", gs.prev_hunk, "Previous hunk")
			nmap("]h", gs.next_hunk, "Next hunk")
			nmap("<leader>hp", gs.preview_hunk, "Preview hunk")
			nmap("<leader>hr", gs.reset_hunk, "Reset hunk")
			nmap("<leader>hs", gs.stage_hunk, "Stage hunk")
			nmap("<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
			nmap("<leader>gg", gs.blame, "Blame")

			-- Text object:
			vim.keymap.set({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<cr>")
		end,
	},
}
