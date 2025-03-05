vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
local keymap = vim.keymap.set

-- Window management
keymap("n", "<leader>\\", "<C-w>v", { desc = "Split window vertically" })
keymap("n", "<leader>-", "<C-w>s", { desc = "Split window horizontally" })
keymap("n", "<leader>=", "<C-w>=", { desc = "Make window size equal" })
keymap("n", "<M-C-l>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })
keymap("n", "<M-C-h>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
keymap("n", "<M-C-j>", "<cmd>horizontal resize +2<cr>", { desc = "Increase window height" })
keymap("n", "<M-C-k>", "<cmd>horizontal resize -2<cr>", { desc = "Decrease window height" })

-- Navigation and movement
keymap("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })
keymap("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center screen" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center screen" })
keymap("n", "n", "nzvzz", { desc = "Next search result, open folds, and center screen" })
keymap("n", "N", "Nzvzz", { desc = "Previous search result, open folds, and center screen" })
keymap("n", "<C-j>", "<cmd>cnext<CR>zz", { desc = "Next quickfix item and center screen" })
keymap("n", "<C-k>", "<cmd>cprev<CR>zz", { desc = "Previous quickfix item and center screen" })

-- Movement and line actions
keymap("n", "<M-down>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
keymap("n", "<M-up>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
keymap("i", "<M-down>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
keymap("i", "<M-up>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
keymap("v", "<M-down>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
keymap("v", "<M-up>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- Line wrapping
keymap({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
keymap({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
keymap({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
keymap({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Terminal mode
keymap("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true, desc = "Exit terminal mode" })

-- Editing and text manipulation
keymap({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })
keymap("v", ">", ">gv", { desc = "Indent and maintain selection" })
keymap("v", "<", "<gv", { desc = "Outdent and maintain selection" })
keymap({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Commenting
keymap("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
keymap("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-- Utility functions
keymap("n", "<leader>ip", vim.show_pos, { desc = "Inspect Pos" })
keymap("n", "<leader>fo", "za", { desc = "Toggle fold under cursor" })
keymap("n", "<leader>x", "<cmd>!chmod +x %<cr>", { silent = true, desc = "Make current file executable" })
keymap("n", "<C-\\>", "<cmd>silent !tmux neww ts<cr>", { desc = "New tmux session" }) -- need to be in tmux already for this to work
keymap("n", "<leader>nf", [[:e <C-R>=expand("%:p:h") . "/" <CR>]], {
	silent = false,
	desc = "Open a new file in the same directory",
})
