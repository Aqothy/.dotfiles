local map = vim.keymap.set

-- Navigation and movement
map("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center screen" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center screen" })
map("n", "n", "nzvzz", { desc = "Next search result, open folds, and center screen" })
map("n", "N", "Nzvzz", { desc = "Previous search result, open folds, and center screen" })
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })
map("n", "<C-t>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<C-]>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<C-[>", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
map({ 'n', 'x', 'o' }, 'H', '^', { desc = "Beginning of line" })
map({ 'n', 'x', 'o' }, 'L', 'g_', { desc = "End of line" })

-- Editing and text manipulation
map("x", ">", ">gv", { desc = "Indent and maintain selection" })
map("x", "<", "<gv", { desc = "Outdent and maintain selection" })
map({ "n", "x", "o" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })
map("n", "c.", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word" })

-- "Whole Buffer" text-object:
map("x", "ig", "gg^oG$", { desc = "Select whole buffer" })
map("o", "ig", "<cmd>normal vig<cr>", { desc = "Operate whole buffer" })

map({ "i", "n", "s" }, "<esc>", function()
    vim.cmd("noh")
    vim.snippet.stop()
    return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

local diagnostic_goto = function(next, severity)
    severity = severity and vim.diagnostic.severity[severity] or nil

    return function()
        vim.diagnostic.jump({ count = next and 1 or -1, float = true, severity = severity })
    end
end

map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
