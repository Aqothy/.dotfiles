vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set("n", "<leader>\\", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
vim.keymap.set("n", "<leader>-", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
vim.keymap.set("n", "<leader>=", "<C-w>=", { desc = "Make window size equal" }) -- make window equal size
vim.keymap.set("n", "+", "<C-a>")
vim.keymap.set("n", "-", "<C-x>")
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "J", "mzJ`z")
--vim.api.nvim_set_keymap("n", "<leader>q", "<cmd>q<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<Esc><Esc>", "<C-\\><C-n>", { noremap = true, silent = true }) -- exit terminal mode
-- vim.keymap.set("n", "<C-d>", "<C-d>zz")
-- vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])
vim.keymap.set("n", "<leader>a", "<cmd>normal ggVG<cr>", { silent = true, desc = "Select all text in the file" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { silent = true }) -- silent so noice doesn't show the command line
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set("n", "<M-j>", "<cmd>resize -2<CR>")
vim.keymap.set("n", "<M-k>", "<cmd>resize +2<CR>")
vim.keymap.set("n", "<M-l>", "<cmd>vertical resize +2<CR>")
vim.keymap.set("n", "<M-h>", "<cmd>vertical resize -2<CR>")
vim.keymap.set("n", "<leader>nh", "<cmd>nohlsearch<CR>", { desc = "Escape and clear hlsearch" })
vim.keymap.set("n", "<C-h>", "<C-w>h") -- Move to the split left
vim.keymap.set("n", "<C-j>", "<C-w>j") -- Move to the split below
vim.keymap.set("n", "<C-k>", "<C-w>k") -- Move to the split above
vim.keymap.set("n", "<C-l>", "<C-w>l") -- Move to the split right
-- line wrap stuff
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
vim.keymap.set("v", "<Tab>", ">gv")
vim.keymap.set("v", "<S-Tab>", "<gv")
vim.keymap.set({ "i", "v", "n" }, "<C-/>", "<cmd>normal gcc<cr>", { silent = true }) -- comment line

vim.keymap.set("n", "<M-l>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<M-h>", "<cmd>cprev<CR>zz")

vim.keymap.set("n", "<leader>fo", "za")

vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
vim.keymap.set("n", "<leader>bo", "<cmd>%bd|e#<cr>", { desc = "Close all buffers but the current one" })

vim.api.nvim_set_keymap("i", "<C-enter>", "copilot#Accept()", { expr = true, silent = true, noremap = false })
vim.keymap.set("i", "<M-]>", "copilot#Next()", { expr = true, silent = true })
vim.keymap.set("i", "<M-[>", "copilot#Previous()", { expr = true, silent = true })

if vim.wo[0].diff then
	print("diff")
end
