vim.g.mapleader = " "
vim.g.maplocalleader = " "
local keymap = vim.keymap.set
keymap("n", "<leader>\\", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap("n", "<leader>-", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap("n", "<leader>=", "<C-w>=", { desc = "Make window size equal" }) -- make window equal size
keymap("n", "+", "<C-a>")
keymap("n", "-", "<C-x>")
keymap("n", "<leader>pv", vim.cmd.Ex)
keymap("n", "J", "mzJ`z")
--vim.api.nvim_set_keymap("n", "<leader>q", "<cmd>q<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<Esc><Esc>", "<C-\\><C-n>", { noremap = true, silent = true }) -- exit terminal mode
keymap("n", "<C-d>", "<C-d>zz")
keymap("n", "<C-u>", "<C-u>zz")
keymap("n", "n", "nzz")
keymap("n", "N", "Nzz")
keymap({ "n", "v" }, "<leader>d", [["_d]])
keymap({ "n", "v" }, "<leader>c", [["_c]])
keymap("n", "<leader>a", "<cmd>normal ggVG<cr>", { silent = true, desc = "Select all text in the file" })
keymap("v", "K", ":m '<-2<CR>gv=gv", { silent = true }) -- silent so noice doesn't show the command line
keymap("v", "J", ":m '>+1<CR>gv=gv", { silent = true })
keymap("n", "<M-j>", "<cmd>resize -2<CR>")
keymap("n", "<M-k>", "<cmd>resize +2<CR>")
keymap("n", "<M-l>", "<cmd>vertical resize +2<CR>")
keymap("n", "<M-h>", "<cmd>vertical resize -2<CR>")
keymap("n", "<C-h>", "<C-w>h") -- Move to the split left
keymap("n", "<C-j>", "<C-w>j") -- Move to the split below
keymap("n", "<C-k>", "<C-w>k") -- Move to the split above
keymap("n", "<C-l>", "<C-w>l") -- Move to the split right
-- line wrap stuff
keymap({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
keymap({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
keymap({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
keymap({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
keymap("v", "<Tab>", ">gv")
keymap("v", "<S-Tab>", "<gv")

-- for in and outside of tmux LOL (commenting)
keymap({ "n", "v", "i" }, "<C-_>", "<cmd>normal gcc<CR>", { desc = "Toggle comment", silent = true })
keymap({ "n", "v", "i" }, "<C-/>", "<cmd>normal gcc<CR>", { desc = "Toggle comment", silent = true })

keymap("n", "<M-l>", "<cmd>cnext<CR>zz")
keymap("n", "<M-h>", "<cmd>cprev<CR>zz")

keymap("n", "<leader>fo", "za")
keymap({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

keymap("n", "<leader>x", "<cmd>!chmod +x %<cr>", { silent = true })
keymap("n", "<leader>bo", "<cmd>%bd|e#<cr>", { desc = "Close all buffers but the current one" })
keymap("n", "<C-k>", "<cmd>silent !tmux neww ts<cr>", { desc = "New tmux session" }) -- need to be in tmux already for this to work
