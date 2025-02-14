return {
	"lervag/vimtex",
	lazy = false, -- no lazy load for vimtex for inverse search function
	config = function()
		vim.g.vimtex_view_method = "skim" -- PDF viewer
		vim.g.vimtex_compiler_method = "latexmk" -- Auto compile with latexmk
		vim.g.vimtex_quickfix_mode = 0 -- Don't open quickfix window_picker
		vim.g.tex_flavor = "latex"
		vim.g.vimtex_mappings_disable = { ["n"] = { "K" } } -- disable `K` as it conflicts with LSP hover
		local function focus_terminal()
			-- Replace "Kitty" with the name of your terminal app if it's different
			vim.fn.system({ "open", "-a", "Kitty" })
		end

		local focus_group = vim.api.nvim_create_augroup("vimtex_event_focus", { clear = true })

		-- Restoring focus to terminal after inverse search
		vim.api.nvim_create_autocmd("User", {
			pattern = "VimtexEventViewReverse",
			group = focus_group,
			callback = focus_terminal,
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
