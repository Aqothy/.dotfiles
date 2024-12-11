vim.g.mapleader = " "
--vim.keymap.set("n", "<leader>v", "<C-w>v")
--vim.keymap.set("n", "<leader>h", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
--vim.api.nvim_set_keymap("v", "cy", '"+y', { noremap = true, silent = true })
--vim.api.nvim_set_keymap("n", "<leader>q", "<cmd>q<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true }) -- exit terminal mode
--vim.keymap.set(
--	"n",
--	"<leader>op",
--	":!open -a Skim <C-r>=expand('%:h')<CR>/aux/<C-r>=expand('%:t:r')<CR>.pdf &<CR>",
--	{ noremap = true, silent = true }
--)
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")
--vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])
vim.keymap.set("n", "<leader>a", "ggVG", { desc = "Select all text in the file" })  -- select all text in the file
vim.keymap.set("n", "<leader>s", [[:cfdo %s/\<<C-r><C-w>\>//gI<left><Left><Left>]]) -- find and replace exact word under cursor in globally
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("n", "<down>", "<cmd>resize +2<CR>")
vim.keymap.set("n", "<up>", "<cmd>resize -2<CR>")
vim.keymap.set("n", "<right>", "<cmd>vertical resize +2<CR>")
vim.keymap.set("n", "<left>", "<cmd>vertical resize -2<CR>")
