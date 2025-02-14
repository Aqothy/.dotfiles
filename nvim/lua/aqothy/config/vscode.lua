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

keymap({ "n", "v" }, "<leader>tt", function()
	vscode.action("workbench.action.togglePanel")
end, { desc = "Toggle Terminal" })

keymap({ "n", "v" }, "<leader>d", [["_d]])
keymap({ "n", "v" }, "<leader>c", [["_c]])

-- Updated keymaps using the `vscode` variable directly
keymap({ "n", "v" }, "<leader>la", function()
	vscode.action("editor.action.quickFix")
end, { desc = "Quick Fix" })

keymap({ "n", "v" }, "<leader>fd", function()
	vscode.action("workbench.actions.view.problems")
end, { desc = "View Problems" })

keymap({ "n", "v" }, "<leader>k", function()
	vscode.action("editor.action.formatDocument")
end, { desc = "Format Document" })

keymap({ "n", "v" }, "K", function()
	vscode.action("editor.action.showHover")
end, { desc = "Show Hover" })

-- vscode-harpoon keymaps
keymap({ "n", "v" }, "<leader>ha", function()
	vscode.action("vscode-harpoon.addEditor")
end, { desc = "Harpoon: Add Editor" })

keymap({ "n", "v" }, "<leader>hh", function()
	vscode.action("vscode-harpoon.editorQuickPick")
end, { desc = "Harpoon: Editor Quick Pick" })

keymap({ "n", "v" }, "<leader>he", function()
	vscode.action("vscode-harpoon.editEditors")
end, { desc = "Harpoon: Edit Editors" })

keymap({ "n", "v" }, "<leader>1", function()
	vscode.action("vscode-harpoon.gotoEditor1")
end, { desc = "Harpoon: Goto Editor 1" })

keymap({ "n", "v" }, "<leader>2", function()
	vscode.action("vscode-harpoon.gotoEditor2")
end, { desc = "Harpoon: Goto Editor 2" })

keymap({ "n", "v" }, "<leader>3", function()
	vscode.action("vscode-harpoon.gotoEditor3")
end, { desc = "Harpoon: Goto Editor 3" })

keymap({ "n", "v" }, "<leader>4", function()
	vscode.action("vscode-harpoon.gotoEditor4")
end, { desc = "Harpoon: Goto Editor 4" })

keymap({ "n", "v" }, "<leader>5", function()
	vscode.action("vscode-harpoon.gotoEditor5")
end, { desc = "Harpoon: Goto Editor 5" })

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
	callback = function()
		(vim.hl or vim.highlight).on_yank({ timeout = 60 })
	end,
})
