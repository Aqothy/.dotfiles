return {
	"lervag/vimtex",
	enabled = false,
	config = function()
		vim.g.vimtex_view_method = "skim" -- PDF viewer
		vim.g.vimtex_compiler_method = "latexmk" -- Auto compile with latexmk
		vim.g.vimtex_quickfix_mode = 0 -- Don't open quickfix window_picker
		vim.g.tex_flavor = "latex"
		vim.g.vimtex_mappings_disable = { ["n"] = { "K" } } -- disable `K` as it conflicts with LSP hover

		-- Restoring focus to terminal after inverse search, cmd + shift + click
		vim.api.nvim_create_autocmd("User", {
			group = vim.api.nvim_create_augroup("vimtex_event_focus", { clear = true }),
			pattern = "VimtexEventViewReverse",
			callback = function()
				-- Replace "Ghostty" with the name of your terminal app if it's different
				vim.fn.system({ "open", "-a", "Ghostty" })
			end,
		})

		vim.g.vimtex_compiler_latexmk = {
			aux_dir = "aux",
			options = {
				"-file-line-error",
				"-interaction=nonstopmode",
				"-synctex=1",
				"-shell-escape",
			},
		}
	end,
}
