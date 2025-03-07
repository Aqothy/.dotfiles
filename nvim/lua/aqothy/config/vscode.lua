local vscode = require("vscode")

vim.g.mapleader = " "
vim.g.maplocalleader = " "
local keymap = vim.keymap.set

vim.notify = vscode.notify

--  Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)
vim.opt.undofile = true
vim.opt.undolevels = 1000
vim.opt.virtualedit = "block"
vim.opt.wildmode = { "longest:full", "full" }
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.whichwrap:append("<,>,[,],h,l") -- allow move to next line with the
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

keymap("v", ">", ">gv", { desc = "Indent and maintain selection" })
keymap("v", "<", "<gv", { desc = "Outdent and maintain selection" })

keymap("n", "<leader>nf", function()
	vscode.call("workbench.action.files.newUntitledFile")
end, {
	desc = "New file",
})

keymap({ "i", "n", "s" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

keymap("n", "<leader>\\", function()
	vscode.call("workbench.action.splitEditor")
end, { desc = "Split editor" })

keymap("n", "<leader>-", function()
	vscode.call("workbench.action.splitEditorDown")
end, { desc = "Split editor down" })

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
keymap({ "n", "v" }, "'s", function()
	vscode.action("vscode-harpoon.addEditor")
end, { desc = "Harpoon: Add Editor" })

keymap({ "n", "v" }, "'e", function()
	vscode.action("vscode-harpoon.editEditors")
end, { desc = "Harpoon: Edit Editors" })

keymap({ "n", "v" }, "'1", function()
	vscode.action("vscode-harpoon.gotoEditor1")
end, { desc = "Harpoon: Goto Editor 1" })

keymap({ "n", "v" }, "'2", function()
	vscode.action("vscode-harpoon.gotoEditor2")
end, { desc = "Harpoon: Goto Editor 2" })

keymap({ "n", "v" }, "'3", function()
	vscode.action("vscode-harpoon.gotoEditor3")
end, { desc = "Harpoon: Goto Editor 3" })

keymap({ "n", "v" }, "'4", function()
	vscode.action("vscode-harpoon.gotoEditor4")
end, { desc = "Harpoon: Goto Editor 4" })

keymap({ "n", "v" }, "'5", function()
	vscode.action("vscode-harpoon.gotoEditor5")
end, { desc = "Harpoon: Goto Editor 5" })

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
	callback = function()
		(vim.hl or vim.highlight).on_yank({ timeout = 60 })
	end,
})
