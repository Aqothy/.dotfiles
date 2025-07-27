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
opt.ignorecase = true
opt.smartcase = true
opt.whichwrap:append("h,l") -- allow move to next line with the
opt.swapfile = false
opt.writebackup = false
opt.updatetime = 300
opt.jumpoptions = { "stack", "view" }

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
map("n", "]r", vscode_action("editor.action.wordHighlight.next"), { desc = "Next Reference" })
map("n", "[r", vscode_action("editor.action.wordHighlight.prev"), { desc = "Prev Reference" })

map("n", "<leader>nf", vscode_action("workbench.action.files.newUntitledFile"), { desc = "New file" })
map("x", ">", ">gv", { desc = "Indent and maintain selection" })
map("x", "<", "<gv", { desc = "Outdent and maintain selection" })
map("n", "<leader>xc", "<cmd>!chmod +x %<cr>", { silent = true, desc = "Make current file executable" })
map("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })
map({ "n", "x", "o" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })

map("n", "<leader>fw", function()
    vscode.action("workbench.action.findInFiles", { args = { query = vim.fn.expand("<cword>") } })
end, { desc = "Search word in files" })

map("n", "u", "<Cmd>call VSCodeNotify('undo')<CR>", { desc = "Undo" })
map("n", "<C-r>", "<Cmd>call VSCodeNotify('redo')<CR>", { desc = "Redo" })

map("n", "<leader>K", vscode_action("editor.action.peekDefinition"), { desc = "Peek Definition" })

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function()
        (vim.hl or vim.highlight).on_yank({ timeout = 60 })
    end,
})
