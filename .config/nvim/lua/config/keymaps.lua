local map = vim.keymap.set

local rep = require("custom.repeat")

-- "Whole Buffer" text-object:
map("x", "ig", "gg^oG$", { desc = "Select whole buffer" })
map("o", "ig", "<cmd>normal vig<cr>", { desc = "Operate whole buffer" })

map("x", ">", ">gv", { desc = "Indent and maintain selection" })
map("x", "<", "<gv", { desc = "Outdent and maintain selection" })
map("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })
map({ "n", "x" }, "<leader>D", [["_d]], { desc = "Delete without yanking" })
map({ "n", "x", "o" }, "H", "^", { desc = "Beginning of line" })
map({ "n", "x", "o" }, "L", "$", { desc = "End of line" })
map("x", "il", "^og_", { desc = "Select line without whitespace" })
map("o", "il", "<cmd>normal vil<cr>", { desc = "Operate line" })
map("x", "y", "ygv<esc>", { desc = "Cursor-in-place copy" })
map("x", "Q", "<cmd>norm @q<CR>", { desc = "Run macro 'q' on selection" })
map("n", "y<c-g>", function()
    vim.fn.setreg("+", vim.fn.expand("%:."))
end, { desc = "Yank relative file path to clipboard" })
map({ "n", "x", "o" }, "M", "%", { remap = true, desc = "Matchit" })
map("n", "<leader>w", "<esc><cmd>update<cr>", { desc = "Save File" })
map("n", "<leader><c-l>", "<Cmd>nohlsearch|diffupdate|normal! <C-L><CR>", { desc = "Redraw" })
map("n", "<leader><c-o>", "<cmd>pop<cr>", { desc = "Pop off tag stack" })

if vim.g.vscode then
    return
end

local next_buffer, prev_buffer = rep.command_pair("bnext", "bprevious")
local next_qf, prev_qf = rep.command_pair("cnext", "cprevious")

-- Navigation and movement
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center screen" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center screen" })
map("n", "n", "nzvzz", { desc = "Next search result, open folds, and center screen" })
map("n", "N", "Nzvzz", { desc = "Previous search result, open folds, and center screen" })
map("n", "<C-i>", "<C-i>zz", { desc = "Jump forward in jump list and center" })
map("n", "<C-o>", "<C-o>zz", { desc = "Jump backward in jump list and center" })
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window" })
map("n", "<a-b>", "<c-^>", { desc = "Alternate buffer" })
map("n", "]b", next_buffer, { desc = "Next Buffer" })
map("n", "[b", prev_buffer, { desc = "Prev Buffer" })
map("n", "]q", next_qf, { desc = "Next Quickfix Item" })
map("n", "[q", prev_qf, { desc = "Prev Quickfix Item" })
map("n", "<a-s-,>", "<c-w>3<", { desc = "Resize window left" })
map("n", "<a-s-.>", "<c-w>3>", { desc = "Resize window right" })
map("n", "<a-s-up>", "3<C-W>+", { desc = "Resize window up" })
map("n", "<a-s-down>", "3<C-W>-", { desc = "Resize window down" })
map("n", "<a-down>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down", silent = true })
map("n", "<a-up>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up", silent = true })
map("i", "<a-down>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down", silent = true })
map("i", "<a-up>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up", silent = true })
map("x", "<a-down>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down", silent = true })
map("x", "<a-up>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up", silent = true })

-- Terminal
map("t", "<c-q>", "<c-\\><c-n>", { desc = "Esc Terminal" })

-- Tabs and windows
map({ "n", "t" }, "<c-]>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map({ "n", "t" }, "<c-[>", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
for i = 1, 5 do
    map("n", "<leader>" .. i, "<cmd>tabnext " .. i .. "<cr>", { desc = "Go to Tab " .. i })
end
map("t", "<esc>", "<esc>", { desc = "Feed Escape" })
map("n", "<leader>\\", "<cmd>vs<cr>", { desc = "New Vertical Split" })
map("n", "<leader><cr>", "<cmd>sp<cr>", { desc = "New Horizontal Split" })
map("n", "<a-]>", "<Cmd>tabmove +1<CR>", { desc = "Move tab right" })
map("n", "<a-[>", "<Cmd>tabmove -1<CR>", { desc = "Move tab left" })
map("n", "<leader>tt", "<cmd>tabnew | term<cr>", { desc = "Tab terminal" })
map("n", "<c-t>", "<cmd>tab split<cr>", { desc = "Open window in new tab" })
map("n", "<c-s-w>", "<cmd>tabclose<CR>", { desc = "Close tab" })
map("n", "<leader>to", "<cmd>tabonly<cr>", { desc = "Close other tabs" })

-- Editing
map("i", "<C-b>", "<Left>", { desc = "Backward char" })
map("c", "<C-b>", "<Left>", { desc = "Backward char" })
map("i", "<C-f>", "<Right>", { desc = "Forward char" })
map("c", "<C-f>", "<Right>", { desc = "Forward char" })
map("s", "<BS>", "<C-o>s", { desc = "Remove Snippet Placeholder" })
map("i", "<C-A>", "<C-O>^", { desc = "Beginning of line" })
map("c", "<C-A>", "<Home>", { desc = "Beginning of line" })
map("i", "<C-E>", "<End>", { desc = "End of line" })
map("c", "<C-E>", "<End>", { desc = "End of line" })
map("i", "<a-f>", "<S-Right>", { desc = "Forward a word" })
map("c", "<a-f>", "<S-Right>", { desc = "Forward a word" })
map("i", "<a-b>", "<S-Left>", { desc = "Backward a word" })
map("c", "<a-b>", "<S-Left>", { desc = "Backward a word" })
map("i", "<a-d>", "<C-O>dw", { desc = "Delete word forward" })
map("c", "<a-d>", "<S-Right><C-W>", { desc = "Delete word forward" })
map("i", "<C-K>", "<C-O>D", { desc = "Kill to end of line" })
map("c", "<C-K>", function()
    local line = vim.fn.getcmdline()
    local pos = vim.fn.getcmdpos()
    vim.fn.setreg("-", string.sub(line, pos))
    vim.fn.setcmdline(string.sub(line, 1, pos - 1))
end, { desc = "Kill to end of line" })
map("c", "<C-U>", function()
    local line = vim.fn.getcmdline()
    local pos = vim.fn.getcmdpos()
    if pos > 1 then
        vim.fn.setreg("-", string.sub(line, 1, pos - 1))
    end
    return "<C-U>"
end, { expr = true, desc = "Kill to beginning of line" })
map("c", "<C-Y>", function()
    return vim.fn.pumvisible() == 1 and "<C-Y>" or "<C-R>-"
end, { expr = true, desc = "Yank last killed text" })
map({ "i", "x", "n", "s" }, "<D-s>", "<esc><cmd>update<cr>", { desc = "Save File" })
map("i", "<C-CR>", "<C-o>o", { desc = "Insert line below" })

-- utils
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa<cr>", { desc = "Quit All" })

map("n", "<a-z>", function()
    vim.wo.wrap = not vim.wo.wrap
end, { desc = "Toggle line wrap" })

map({ "i", "n", "s" }, "<esc>", function()
    vim.cmd("noh")
    vim.snippet.stop()
    return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

local next_diag, prev_diag = rep.pair(function()
    vim.diagnostic.jump({ count = vim.v.count1 })
end, function()
    vim.diagnostic.jump({ count = -vim.v.count1 })
end)
local next_error, prev_error = rep.pair(function()
    vim.diagnostic.jump({ count = vim.v.count1, severity = vim.diagnostic.severity.ERROR })
end, function()
    vim.diagnostic.jump({ count = -vim.v.count1, severity = vim.diagnostic.severity.ERROR })
end)

map("n", "]d", next_diag, { desc = "Next Diagnostic" })
map("n", "[d", prev_diag, { desc = "Prev Diagnostic" })
map("n", "]e", next_error, { desc = "Next Error" })
map("n", "[e", prev_error, { desc = "Prev Error" })
map("n", "gh", vim.diagnostic.open_float, { desc = "Diagnostic Float" })
map("n", "yd", function()
    local diags = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
    local n_diags = #diags

    local function yank(msg)
        if not msg then
            return
        end
        vim.fn.setreg('"', msg)
        vim.fn.setreg(vim.v.register, msg)
    end

    if n_diags == 1 then
        local msg = diags[1].message
        yank(msg)
        return
    end

    vim.ui.select(
        vim.tbl_map(function(d)
            return d.message
        end, diags),
        { prompt = "Select diagnostic message to yank: " },
        yank
    )
end, { desc = "Yank diagnostic message on current line" })

map("n", "<leader>pm", "<cmd>Lazy<cr>", { desc = "Package Manager" })
