local vscode = require("vscode")

local map = vim.keymap.set
local opt = vim.opt

vim.notify = vscode.notify

-- https://github.com/vscode-neovim/vscode-neovim/issues/2507
opt.cmdheight = 999

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
map({ "n", "x" }, "<leader>hs", vscode_action("git.stageSelectedRanges"), { desc = "Stage hunk" })
map({ "n", "x" }, "<leader>hr", vscode_action("git.revertSelectedRanges"), { desc = "Revert hunk" })
map("n", "/", vscode_action("actions.find"), { desc = "Find in file" })

map("x", ">", ">gv", { desc = "Indent and maintain selection" })
map("x", "<", "<gv", { desc = "Outdent and maintain selection" })
map("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })
map({ "n", "x", "o" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })
map({ "n", "x", "o" }, "H", "^", { desc = "Beginning of line" })
map({ "n", "x", "o" }, "L", "g_", { desc = "End of line" })
map("x", "il", "^og_", { desc = "Select line without whitespace" })
map("x", "y", "ygv<esc>", { desc = "Cursor-in-place copy" })
map("n", "c.", ":%s/<c-r><c-w>//gc<Left><Left><Left>", { desc = "Replace word" })
map("n", "g.", ":%s///gc<Left><Left><Left><Left>", { desc = "Replace" })
map("x", "g.", ":s///gc<Left><Left><Left><Left>", { desc = "Replace" })
map("n", "y<c-g>", function()
    vim.fn.setreg("+", vim.fn.expand("%:."))
end, { desc = "Yank relative file path to clipboard" })

vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function()
        (vim.hl or vim.highlight).on_yank({ timeout = 60 })
    end,
})

-- https://github.com/vscode-neovim/vscode-neovim/issues/2117
local redraw_group = vim.api.nvim_create_augroup("RedrawOnDelete", { clear = true })
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = redraw_group,
    callback = function()
        if vim.fn.mode() == "n" then
            vim.cmd("silent! mode") -- refresh UI after delete/insert
        end
    end,
})

return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            highlight = { enabled = false },
            indent = { enabled = false },
        },
    },
}
