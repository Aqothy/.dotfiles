return {
	{
		"lervag/vimtex", -- Main LaTeX plugin for Neovim
		lazy = false,
		tag = "v2.15",
		config = function()
			-- Configuration for vimtex
			vim.g.vimtex_view_method = "skim" -- PDF viewer
			vim.g.vimtex_compiler_method = "latexmk" -- Auto compile with latexmk
			vim.g.vimtex_compiler_latexmk = {
				options = {
					"-pdf",
					"-outdir=aux",
				},
			}
		end,
	},
}
