local map = vim.keymap.set

-- Navigation and movement
map("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center screen" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center screen" })
map("n", "n", "nzvzz", { desc = "Next search result, open folds, and center screen" })
map("n", "N", "Nzvzz", { desc = "Previous search result, open folds, and center screen" })
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Tabs
map("n", "<leader>to", "<cmd>tabonly<cr>", { desc = "Close other tabs" })
map("n", "<c-]>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<c-[>", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
map("t", "<c-[>", "<c-\\><c-n>", { desc = "Esc Terminal" })
map("t", "<esc>", function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", false)
end, { desc = "Feed esc" })
map("n", "<leader>\\", function()
    if vim.bo.buftype == "terminal" then
        return "<cmd>vs | term<cr>"
    else
        return "<cmd>vs<cr>"
    end
end, { desc = "New Vertical Split", expr = true })
map("n", "<leader><cr>", function()
    if vim.bo.buftype == "terminal" then
        return "<cmd>sp | term<cr>"
    else
        return "<cmd>sp<cr>"
    end
end, { desc = "New Horizontal Split", expr = true })
map("n", "<a-]>", "<Cmd>tabmove +1<CR>", { desc = "Move tab right" })
map("n", "<a-[>", "<Cmd>tabmove -1<CR>", { desc = "Move tab left" })
map("n", "<leader>tt", "<cmd>tabnew | terminal<CR>", { desc = "Open terminal in new tab" })
map("n", "<leader>x", "<cmd>tabclose<CR>", { desc = "Close tab" })
map("n", "<c-t>", "<cmd>tabnew<cr>", { desc = "New tab" })
map("n", "<leader>ts", "<cmd>tab split<cr>", { desc = "Clone window in new tab" })

-- Editing and text manipulation
map("x", ">", ">gv", { desc = "Indent and maintain selection" })
map("x", "<", "<gv", { desc = "Outdent and maintain selection" })
map({ "n", "x", "o" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })
map("x", "il", "^og_", { desc = "Select line without whitespace" })
map("o", "il", "<cmd>normal vil<cr>", { desc = "Operate line" })
map("x", "y", "ygv<esc>", { desc = "Cursor-in-place copy" })
map("n", "c.", ":%s/<C-r><C-w>//gc<Left><Left><Left>", { desc = "Replace instances of word" })
map("i", "<c-e>", "<c-o>$", { desc = "End" })
map("i", "<c-a>", "<c-o>^", { desc = "Home" })
map("n", "<localleader>x", "<cmd>source %<cr>", { desc = "Source file" })
map("s", "<BS>", "<C-o>s", { desc = "Remove Snippet Placeholder" })

-- "Whole Buffer" text-object:
map("x", "ig", "gg^oG$", { desc = "Select whole buffer" })
map("o", "ig", "<cmd>normal vig<cr>", { desc = "Operate whole buffer" })

if vim.fn.has("mac") == 1 then
    map({ "i", "x", "n", "s" }, "<D-s>", "<esc><cmd>update<cr>", { desc = "Save File" })
else
    map({ "i", "x", "n", "s" }, "<C-s>", "<esc><cmd>update<cr>", { desc = "Save File" })
end
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa<cr>", { desc = "Quit All" })

map({ "i", "n", "s" }, "<esc>", function()
    vim.cmd("noh")
    vim.snippet.stop()
    return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

local diagnostic_goto = function(next, severity)
    severity = severity and vim.diagnostic.severity[severity] or nil

    return function()
        vim.diagnostic.jump({ count = (next and 1 or -1) * vim.v.count1, float = true, severity = severity })
    end
end

map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "<c-e>", vim.diagnostic.open_float, { desc = "Open diagnostic float" })

map("n", "<leader>pm", "<cmd>Lazy<cr>", { desc = "Package Manager" })
