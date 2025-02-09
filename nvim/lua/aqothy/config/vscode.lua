local vscode = require("vscode")

vim.g.mapleader = " "
vim.g.maplocalleader = " "
local keymap = vim.keymap.set

vim.notify = vscode.notify

vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.undolevels = 1000
vim.opt.virtualedit = "block"
vim.opt.wildmode = "longest:full,full" -- Command-line completion mode
vim.opt.ignorecase = true
vim.opt.smartcase = true

keymap("n", "<leader>nf", function()
	vscode.call("workbench.action.files.newUntitledFile")
end, {
	desc = "New file",
})

keymap({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

keymap("n", "<leader>ff", function()
	vscode.call("workbench.action.quickOpen")
end, {
	desc = "Open file finder",
})

keymap("n", "<leader>bd", function()
	vscode.call("workbench.action.closeActiveEditor")
end, {
	desc = "Close buffer",
})

keymap("n", "<leader>bo", function()
	vscode.call("workbench.action.closeAllEditors")
end, {
	desc = "Close buffer",
})


keymap("n", "<leader>fs", function()
	vscode.call("workbench.action.findInFiles")
end, {
	desc = "Search in files",
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
	callback = function()
		(vim.hl or vim.highlight).on_yank({ timeout = 60 })
	end,
})
