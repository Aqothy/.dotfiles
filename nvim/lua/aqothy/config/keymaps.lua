local keymap = vim.keymap.set

-- Window management
keymap("n", "<leader>\\", "<C-w>v", { desc = "Split window vertically" })
keymap("n", "<leader>-", "<C-w>s", { desc = "Split window horizontally" })
keymap("n", "<leader>=", "<C-w>=", { desc = "Make window size equal" })

-- Navigation and movement
keymap("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })
keymap("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center screen" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center screen" })
keymap("n", "n", "nzvzz", { desc = "Next search result, open folds, and center screen" })
keymap("n", "N", "Nzvzz", { desc = "Previous search result, open folds, and center screen" })
keymap("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
keymap("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })

-- Line wrapping
keymap({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
keymap({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Terminal mode
keymap("t", "<esc>", "<C-\\><C-n>", { noremap = true, silent = true, desc = "Exit terminal mode" })

-- Editing and text manipulation
keymap({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })
keymap({ "n", "v" }, "<leader>c", [["_c]], { desc = "Change without yanking" })
keymap("v", ">", ">gv", { desc = "Indent and maintain selection" })
keymap("v", "<", "<gv", { desc = "Outdent and maintain selection" })
keymap({ "i", "n", "s" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Utility functions
keymap("n", "<leader>x", "<cmd>!chmod +x %<cr>", { silent = true, desc = "Make current file executable" })
keymap("n", "<C-h>", "<cmd>silent !tmux neww ts<cr>", { desc = "New tmux session" }) -- need to be in tmux already for this to work
keymap("n", "<leader>nf", [[:e <C-R>=expand("%:p:h") . "/" <CR>]], {
	silent = false,
	desc = "Open a new file in the same directory",
})

keymap("n", "<leader>pm", "<cmd>Lazy<CR>", { desc = "Open package manager" })
