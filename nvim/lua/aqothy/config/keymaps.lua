vim.g.mapleader = " "
vim.g.maplocalleader = " "
local keymap = vim.keymap.set

keymap("n", "<leader>\\", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap("n", "<leader>-", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap("n", "<leader>=", "<C-w>=", { desc = "Make window size equal" }) -- make window equal size

keymap("n", "<leader>pv", vim.cmd.Ex)
keymap("n", "J", "mzJ`z")
keymap("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true }) -- exit terminal mode

keymap("n", "<C-d>", "<C-d>zz")
keymap("n", "<C-u>", "<C-u>zz")

keymap("n", "n", "nzvzz", { desc = "Next search result, open folds, and center screen" })
keymap("n", "N", "Nzvzz", { desc = "Previous search result, open folds, and center screen" })

keymap({ "n", "v" }, "<leader>d", [["_d]])

keymap("n", "<M-right>", "<cmd>vertical resize +2<cr>") -- make the window biger vertically
keymap("n", "<M-left>", "<cmd>vertical resize -2<cr>") -- make the window smaller vertically
keymap("n", "<M-down>", "<cmd>horizontal resize +2<cr>") -- make the window bigger horizontally
keymap("n", "<M-up>", "<cmd>horizontal resize -2<cr>") -- make the window smaller horizontally

-- line wrap stuff
keymap({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
keymap({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
keymap({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
keymap({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

keymap("v", ">", ">gv")
keymap("v", "<", "<gv")

keymap("n", "<C-j>", "<cmd>cnext<CR>zz")
keymap("n", "<C-k>", "<cmd>cprev<CR>zz")

keymap("n", "<leader>fo", "za")
keymap({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

keymap("n", "<leader>x", "<cmd>!chmod +x %<cr>", { silent = true })
keymap("n", "<C-\\>", "<cmd>silent !tmux neww ts<cr>", { desc = "New tmux session" }) -- need to be in tmux already for this to work

keymap("n", "<leader>nf", [[:e <C-R>=expand("%:p:h") . "/" <CR>]], {
	silent = false,
	desc = "Open a new file in the same directory",
})
