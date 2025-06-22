local vscode = require("vscode")

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
local keymap = vim.keymap.set

vim.notify = vscode.notify
vim.g.clipboard = vim.g.vscode_clipboard

--  Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function()
    vim.opt.clipboard = "unnamedplus"
end)

vim.opt.virtualedit = "block"
vim.opt.wildignore:append({ ".DS_Store" })
vim.opt.wildignorecase = true
vim.opt.wildmode = { "longest:full", "full" }
vim.opt.wildoptions:append({ "fuzzy" })
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.whichwrap:append("h,l") -- allow move to next line with the
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.updatetime = 300
vim.opt.jumpoptions = { "stack", "view", "clean" }

local function vscode_action(cmd)
    return function()
        vscode.action(cmd)
    end
end

-- "Whole Buffer" text-object:
keymap("x", "ig", "gg^oG$", { desc = "Select whole buffer" })
keymap("o", "ig", "<cmd>normal vig<cr>", { desc = "Operate whole buffer" })

keymap("n", "]d", vscode_action("editor.action.marker.next"), { desc = "Next diagnostic" })
keymap("n", "[d", vscode_action("editor.action.marker.prev"), { desc = "Previous diagnostic" })
keymap("n", "[h", vscode_action("workbench.action.editor.previousChange"), { desc = "Previous change" })
keymap("n", "]h", vscode_action("workbench.action.editor.nextChange"), { desc = "Next change" })
keymap("n", "[b", vscode_action("workbench.action.previousEditor"), { desc = "Previous buffer" })
keymap("n", "]b", vscode_action("workbench.action.nextEditor"), { desc = "Next buffer" })

keymap("n", "<leader>gs", vscode_action("workbench.view.scm"), { desc = "Source control" })
keymap("n", "<leader>nf", vscode_action("workbench.action.files.newUntitledFile"), { desc = "New file" })
keymap("n", "<leader>\\", vscode_action("workbench.action.splitEditor"), { desc = "Split editor" })
keymap("n", "<leader>-", vscode_action("workbench.action.splitEditorDown"), { desc = "Split editor down" })
keymap("n", "<leader>ee", vscode_action("workbench.action.toggleSidebarVisibility"), { desc = "Toggle Explorer" })
keymap("n", "<leader>bd", vscode_action("workbench.action.closeActiveEditor"), { desc = "Close buffer" })
keymap("n", "<leader>bo", vscode_action("workbench.action.closeAllEditors"), { desc = "Close buffer" })
keymap("n", "za", vscode_action("editor.toggleFold"), { desc = "Toggle fold" })
keymap("n", "<leader>nn", vscode_action("notifications.clearAll"), { desc = "Clear all notifications" })
keymap("x", ">", ">gv", { desc = "Indent and maintain selection" })
keymap("x", "<", "<gv", { desc = "Outdent and maintain selection" })
keymap("n", "<leader>fd", vscode_action("workbench.actions.view.problems"), { desc = "View Problems" })
keymap("n", "<leader>F", vscode_action("editor.action.formatDocument"), { desc = "Format Document" })
keymap("x", "<leader>F", vscode_action("editor.action.formatSelection"), { desc = "Format Selection" })
keymap("n", "<leader>xc", "<cmd>!chmod +x %<cr>", { silent = true, desc = "Make current file executable" })
keymap("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })
keymap({ "n", "x", "o" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })
keymap("n", "<leader>zz", vscode_action("workbench.action.toggleZenMode"), { desc = "Toggle ZenMode" })

keymap("n", "<leader>ff", vscode_action("workbench.action.quickOpen"), { desc = "Open file finder" })
keymap("n", "<leader>fs", vscode_action("workbench.action.findInFiles"), { desc = "Search in files" })
keymap("n", "<leader>pn", vscode_action("notifications.showList"), { desc = "Show Notifications" })
keymap("n", "<leader>fw", function()
    vscode.action("workbench.action.findInFiles", { args = { query = vim.fn.expand("<cword>") } })
end, { desc = "Search word in files" })

keymap("n", "u", "<Cmd>call VSCodeNotify('undo')<CR>", { desc = "Undo" })
keymap("n", "<C-r>", "<Cmd>call VSCodeNotify('redo')<CR>", { desc = "Redo" })

keymap("n", "K", vscode_action("editor.action.showHover"), { desc = "Show Hover" })
keymap("n", "<leader>k", vscode_action("editor.action.peekDefinition"), { desc = "Peek Definition" })
keymap("n", "<leader>ls", vscode_action("workbench.action.gotoSymbol"), { desc = "Show Symbols" })
keymap({ "n", "x" }, "gra", vscode_action("editor.action.quickFix"), { desc = "Quick Fix" })
keymap("n", "grr", vscode_action("editor.action.goToReferences"), { desc = "Go to references" })
keymap("n", "grn", vscode_action("editor.action.rename"), { desc = "Rename symbol" })
keymap("n", "gy", vscode_action("editor.action.goToTypeDefinition"), { desc = "Goto Type Definition" })

keymap("n", "<leader>m", vscode_action("vscode-harpoon.addEditor"), { desc = "Harpoon: Add Editor" })
keymap("n", "<leader>M", vscode_action("vscode-harpoon.editEditors"), { desc = "Harpoon: Edit Editors" })

for i = 1, 5 do
    keymap("n", "<leader>" .. i, vscode_action("vscode-harpoon.gotoEditor" .. i), {
        desc = "Harpoon: Goto Editor " .. i,
    })
end

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function()
        (vim.hl or vim.highlight).on_yank({ timeout = 60 })
    end,
})

-- require("aqothy.config.utils").cowboy()
