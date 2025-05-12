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
keymap("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
keymap("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- Line wrapping
keymap({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
keymap({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Editing and text manipulation
keymap({ "n", "x", "o" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })
keymap("v", ">", ">gv", { desc = "Indent and maintain selection" })
keymap("v", "<", "<gv", { desc = "Outdent and maintain selection" })
keymap({ "i", "n", "s" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Resize windows
keymap("n", "<C-9>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
keymap("n", "<C-0>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
keymap("n", "<C-->", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
keymap("n", "<C-=>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Utils
keymap("n", "<leader>xc", "<cmd>!chmod +x %<cr>", { silent = true, desc = "Make current file executable" })
keymap("n", "<leader>nf", [[:e <C-R>=expand("%:p:h") . "/" <CR>]], { silent = false, desc = "Open a new file in the same directory" })
keymap("n", "<leader>ip", vim.show_pos, { desc = "Inspect Pos" })
keymap("n", "<leader>it", function() vim.treesitter.inspect_tree() vim.api.nvim_input("I") end, { desc = "Inspect Tree" })
keymap("n", "<leader>pm", "<cmd>Lazy<CR>", { desc = "Open package manager" })
keymap("x", "@", function()
	vim.ui.input({ prompt = "Macro Register: " }, function(reg)
		vim.cmd([['<,'>normal @]] .. reg)
	end)
end, { silent = false })
keymap("t", "<c-.>", "<c-\\><c-n>", { desc = "Escape Terminal Mode" })
keymap("n", "<leader>pv", vim.cmd.Ex, { desc = "NETRW" })
keymap("n", "<leader>sh", "<cmd>messages<cr>", { desc = "Show Message History" })

-- "Whole Buffer" text-object:
keymap("x", "ig", "gg^oG$", { desc = "Select whole buffer" })
keymap("o", "ig", "<cmd>normal vig<cr>", { desc = "Operate whole buffer" })
