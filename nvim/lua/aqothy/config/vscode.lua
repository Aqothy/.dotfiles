local vscode = require("vscode")

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
local map = vim.keymap.set
local opt = vim.opt

vim.notify = vscode.notify

--  Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function()
    opt.clipboard = "unnamedplus"
end)

opt.virtualedit = "block"
opt.wildignore:append({ ".DS_Store" })
opt.wildignorecase = true
opt.wildmode = { "longest:full", "full" }
opt.wildoptions:append({ "fuzzy" })
opt.ignorecase = true
opt.smartcase = true
opt.whichwrap:append("h,l") -- allow move to next line with the
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.updatetime = 300
opt.jumpoptions = { "stack", "view", "clean" }

local function vscode_action(cmd)
    return function()
        vscode.action(cmd)
    end
end

-- "Whole Buffer" text-object:
map("x", "ig", "gg^oG$", { desc = "Select whole buffer" })
map("o", "ig", "<cmd>normal vig<cr>", { desc = "Operate whole buffer" })

map("n", "]d", vscode_action("editor.action.marker.next"), { desc = "Next diagnostic" })
map("n", "[d", vscode_action("editor.action.marker.prev"), { desc = "Previous diagnostic" })
map("n", "[h", vscode_action("workbench.action.editor.previousChange"), { desc = "Previous change" })
map("n", "]h", vscode_action("workbench.action.editor.nextChange"), { desc = "Next change" })
map("n", "H", vscode_action("workbench.action.previousEditor"), { desc = "Previous buffer" })
map("n", "L", vscode_action("workbench.action.nextEditor"), { desc = "Next buffer" })

map("n", "<leader>gs", vscode_action("workbench.view.scm"), { desc = "Source control" })
map("n", "<leader>nf", vscode_action("workbench.action.files.newUntitledFile"), { desc = "New file" })
map("n", "<leader>\\", vscode_action("workbench.action.splitEditor"), { desc = "Split editor" })
map("n", "<leader>-", vscode_action("workbench.action.splitEditorDown"), { desc = "Split editor down" })
map("n", "<leader>ee", vscode_action("workbench.action.toggleSidebarVisibility"), { desc = "Toggle Explorer" })
map("n", "<leader>bd", vscode_action("workbench.action.closeActiveEditor"), { desc = "Close buffer" })
map("n", "<leader>bo", vscode_action("workbench.action.closeAllEditors"), { desc = "Close all buffers" })
map("n", "za", vscode_action("editor.toggleFold"), { desc = "Toggle fold" })
map("n", "<leader>nn", vscode_action("notifications.clearAll"), { desc = "Clear all notifications" })
map("x", ">", ">gv", { desc = "Indent and maintain selection" })
map("x", "<", "<gv", { desc = "Outdent and maintain selection" })
map("n", "<leader>fd", vscode_action("workbench.actions.view.problems"), { desc = "View Problems" })
map("n", "<leader>F", vscode_action("editor.action.formatDocument"), { desc = "Format Document" })
map("x", "<leader>F", vscode_action("editor.action.formatSelection"), { desc = "Format Selection" })
map("n", "<leader>xc", "<cmd>!chmod +x %<cr>", { silent = true, desc = "Make current file executable" })
map("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })
map({ "n", "x", "o" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })
map("n", "<leader>zz", vscode_action("workbench.action.toggleZenMode"), { desc = "Toggle ZenMode" })

map("n", "<leader>ff", vscode_action("workbench.action.quickOpen"), { desc = "Open file finder" })
map("n", "<leader>fs", vscode_action("workbench.action.findInFiles"), { desc = "Search in files" })
map("n", "<leader>pn", vscode_action("notifications.showList"), { desc = "Show Notifications" })
map("n", "<leader>fw", function()
    vscode.action("workbench.action.findInFiles", { args = { query = vim.fn.expand("<cword>") } })
end, { desc = "Search word in files" })

map("n", "u", "<Cmd>call VSCodeNotify('undo')<CR>", { desc = "Undo" })
map("n", "<C-r>", "<Cmd>call VSCodeNotify('redo')<CR>", { desc = "Redo" })

map("n", "K", vscode_action("editor.action.showHover"), { desc = "Show Hover" })
map("n", "<leader>K", vscode_action("editor.action.peekDefinition"), { desc = "Peek Definition" })
map("n", "<leader>ls", vscode_action("workbench.action.gotoSymbol"), { desc = "Show Symbols" })
map("n", "<leader>lS", vscode_action("workbench.action.showAllSymbols"), { desc = "Show Workspace Symbols" })
map({ "n", "x" }, "gra", vscode_action("editor.action.quickFix"), { desc = "Quick Fix" })
map("n", "grr", vscode_action("editor.action.goToReferences"), { desc = "Go to references" })
map("n", "grn", vscode_action("editor.action.rename"), { desc = "Rename symbol" })
map("n", "grt", vscode_action("editor.action.goToTypeDefinition"), { desc = "Goto Type Definition" })

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function()
        (vim.hl or vim.highlight).on_yank({ timeout = 60 })
    end,
})

-- require("aqothy.config.utils").cowboy()
