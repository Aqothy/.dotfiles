local vscode = require("vscode")

vim.g.mapleader = " "
vim.g.maplocalleader = " "
local keymap = vim.keymap.set

vim.notify = vscode.notify
vim.g.clipboard = vim.g.vscode_clipboard

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
vim.opt.showcmd = false

local function vscode_action(cmd)
	return function()
		vscode.action(cmd)
	end
end

keymap("v", ">", ">gv", { desc = "Indent and maintain selection" })
keymap("v", "<", "<gv", { desc = "Outdent and maintain selection" })

-- "Whole Buffer" text-object:
keymap("x", "ig", "gg^oG$")
keymap("o", "ig", "<cmd>normal vig<cr>")

keymap("n", "za", vscode_action("editor.toggleFold"), { desc = "Toggle fold" })

keymap({ "i", "n", "s" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

keymap("n", "]d", vscode_action("editor.action.marker.next"), { desc = "Next diagnostic" })
keymap("n", "[d", vscode_action("editor.action.marker.prev"), { desc = "Previous diagnostic" })

keymap("n", "[h", vscode_action("workbench.action.editor.previousChange"), { desc = "Previous change" })
keymap("n", "]h", vscode_action("workbench.action.editor.nextChange"), { desc = "Next change" })
keymap("n", "<leader>gd", vscode_action("workbench.view.scm"), { desc = "Source control" })

keymap("n", "<leader>nf", vscode_action("workbench.action.files.newUntitledFile"), { desc = "New file" })

keymap({ "i", "n", "s" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

keymap("n", "<leader>\\", vscode_action("workbench.action.splitEditor"), { desc = "Split editor" })

keymap("n", "<leader>-", vscode_action("workbench.action.splitEditorDown"), { desc = "Split editor down" })

keymap("n", "<leader>ff", vscode_action("workbench.action.quickOpen"), { desc = "Open file finder" })
keymap("n", "<leader>fs", vscode_action("workbench.action.findInFiles"), { desc = "Search in files" })

keymap("n", "<leader>ee", vscode_action("workbench.action.toggleSidebarVisibility"), { desc = "Toggle Explorer" })

keymap("n", "<leader>bd", vscode_action("workbench.action.closeActiveEditor"), { desc = "Close buffer" })
keymap("n", "<leader>bo", vscode_action("workbench.action.closeAllEditors"), { desc = "Close buffer" })

keymap("n", "grn", vscode_action("editor.action.rename"), { desc = "Rename symbol" })

keymap("n", "u", "<Cmd>call VSCodeNotify('undo')<CR>", { desc = "Undo" })
keymap("n", "<C-r>", "<Cmd>call VSCodeNotify('redo')<CR>", { desc = "Redo" })

keymap("n", "grr", vscode_action("editor.action.goToReferences"), { desc = "Go to references" })

keymap({ "n", "v" }, "<leader>tt", vscode_action("workbench.action.togglePanel"), { desc = "Toggle Terminal" })

keymap({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })

keymap({ "n", "v" }, "<leader>la", vscode_action("editor.action.quickFix"), { desc = "Quick Fix" })
keymap({ "n", "v" }, "<leader>fd", vscode_action("workbench.actions.view.problems"), { desc = "View Problems" })

keymap({ "n", "v" }, "<leader>F", vscode_action("editor.action.formatDocument"), { desc = "Format Document" })

keymap({ "n", "v" }, "K", vscode_action("editor.action.showHover"), { desc = "Show Hover" })

keymap({ "n", "v" }, "'s", vscode_action("vscode-harpoon.addEditor"), { desc = "Harpoon: Add Editor" })

keymap({ "n", "v" }, "'e", vscode_action("vscode-harpoon.editEditors"), { desc = "Harpoon: Edit Editors" })

keymap({ "n", "v" }, "'1", vscode_action("vscode-harpoon.gotoEditor1"), { desc = "Harpoon: Goto Editor 1" })

keymap({ "n", "v" }, "'2", vscode_action("vscode-harpoon.gotoEditor2"), { desc = "Harpoon: Goto Editor 2" })

keymap({ "n", "v" }, "'3", vscode_action("vscode-harpoon.gotoEditor3"), { desc = "Harpoon: Goto Editor 3" })

keymap({ "n", "v" }, "'4", vscode_action("vscode-harpoon.gotoEditor4"), { desc = "Harpoon: Goto Editor 4" })

keymap({ "n", "v" }, "'5", vscode_action("vscode-harpoon.gotoEditor5"), { desc = "Harpoon: Goto Editor 5" })

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
	callback = function()
		(vim.hl or vim.highlight).on_yank({ timeout = 60 })
	end,
})
