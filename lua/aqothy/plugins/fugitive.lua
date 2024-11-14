return {
	"tpope/vim-fugitive",
	config = function()
		-- Configure key mappings here for common Git commands
		local map = vim.api.nvim_set_keymap
		local opts = { noremap = true, silent = true }

		-- Open Git status
		map("n", "<leader>gs", ":Git<CR>", opts)

		-- Git pull
		map("n", "<leader>pm", ":Git pull --no-rebase<CR>", opts)

		-- Git push
		map("n", "<leader>p", ":Git push<CR>", opts)

		-- Git commit
		map("n", "<leader>gc", ":Git commit<CR>", opts)

		-- Git add all changes
		map("n", "<leader>ga", ":Git add .<CR>", opts)

		map("n", "<leader>gpu", ":Git push -u origin HEAD<CR>", opts)
	end,
}
