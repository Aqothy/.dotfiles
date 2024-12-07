return {
	"tpope/vim-fugitive",
	config = function()
		vim.keymap.set("n", "<leader>gs", "<cmd>Git<CR>")
		vim.keymap.set("n", "gh", "<cmd>diffget //2<CR>")
		vim.keymap.set("n", "gl", "<cmd>diffget //3<CR>")
--		vim.keymap.set("n", "<leader>gd", "<cmd>Gvdiffsplit!<CR>", { desc = "Open Fugitive vertical diff" })
	end,
}
