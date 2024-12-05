return {
	{
		"lervag/vimtex", -- Main LaTeX plugin for Neovim
		lazy = false,
		tag = "v2.15",
		config = function()
			-- Configuration for vimtex
			vim.g.vimtex_view_method = "skim" -- PDF viewer
			vim.g.vimtex_compiler_method = "latexmk" -- Auto compile with latexmk
			vim.g.vimtex_quickfix_mode = 0 -- Don't open quickfix window_picker
			vim.keymap.set("n", "<leader>lv", ":VimtexView<CR>", { desc = "Open VimTeX PDF viewer" })
			vim.keymap.set("n", "<leader>ll", ":VimtexCompile<CR>", { desc = "Start VimTeX compilation" })
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
	},
}
