vim.g.mapleader = " "
vim.keymap.set("n", "<leader>s", "<C-w>v")
vim.keymap.set("n", "<leader>h", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
vim.api.nvim_set_keymap("v", "cy", '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>q", ":q<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
vim.keymap.set(
	"n",
	"<leader>op",
	":!open -a Skim <C-r>=expand('%:h')<CR>/aux/<C-r>=expand('%:t:r')<CR>.pdf &<CR>",
	{ noremap = true, silent = true }
)
