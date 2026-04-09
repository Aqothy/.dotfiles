local vscode = require("vscode")
local rep = require("custom.repeat")

local map = vim.keymap.set
local opt = vim.opt

vim.notify = vscode.notify

-- https://github.com/vscode-neovim/vscode-neovim/issues/2507
opt.cmdheight = 999
-- setting relativenumber causes flicker in vscode neovim extension?
opt.relativenumber = false

local function vscode_action(cmd)
    return function()
        vscode.action(cmd)
    end
end

local next_diag, prev_diag =
    rep.pair(vscode_action("editor.action.marker.next"), vscode_action("editor.action.marker.prev"))
local next_hunk, prev_hunk = rep.pair(
    vscode_action("workbench.action.editor.nextChange"),
    vscode_action("workbench.action.editor.previousChange")
)
local next_word, prev_word =
    rep.pair(vscode_action("editor.action.wordHighlight.next"), vscode_action("editor.action.wordHighlight.prev"))

map("n", "]d", next_diag, { desc = "Next diagnostic" })
map("n", "[d", prev_diag, { desc = "Previous diagnostic" })
map("n", "]h", next_hunk, { desc = "Next change" })
map("n", "[h", prev_hunk, { desc = "Previous change" })
map({ "n", "x" }, "<leader>hs", vscode_action("git.stageSelectedRanges"), { desc = "Stage hunk" })
map({ "n", "x" }, "<leader>hr", vscode_action("git.revertSelectedRanges"), { desc = "Revert hunk" })
map("n", "<C-h>", vscode_action("workbench.action.navigateLeft"), { desc = "Go to Left Window" })
map("n", "<C-j>", vscode_action("workbench.action.navigateDown"), { desc = "Go to Lower Window" })
map("n", "<C-k>", vscode_action("workbench.action.navigateUp"), { desc = "Go to Upper Window" })
map("n", "<C-l>", vscode_action("workbench.action.navigateRight"), { desc = "Go to Right Window" })
map("n", "]r", next_word, { desc = "Next Word Highlight" })
map("n", "[r", prev_word, { desc = "Previous Word Highlight" })

map({ "i", "n", "s" }, "<esc>", function()
    vim.cmd("noh")
    return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

-- https://github.com/vscode-neovim/vscode-neovim/issues/2117
local vscode_group = vim.api.nvim_create_augroup("aqothy/vscode", { clear = true })
local autocmd = vim.api.nvim_create_autocmd

autocmd("TextChanged", {
    group = vscode_group,
    callback = function()
        if vim.fn.mode() == "n" then
            vim.cmd("silent! mode") -- refresh UI after delete
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
    {
        "saghen/blink.indent",
        opts = {
            static = {
                enabled = false,
            },
            scope = {
                enabled = false,
            },
        },
    },
}
