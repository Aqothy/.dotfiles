local map = vim.keymap.set

local rep = require("custom.repeat")

-- "Whole Buffer" text-object:
map("x", "ie", "gg^oG$", { desc = "Select whole buffer" })
map("o", "ie", "<cmd>normal vie<cr>", { desc = "Operate whole buffer" })

map("x", ">", ">gv", { desc = "Indent and maintain selection" })
map("x", "<", "<gv", { desc = "Outdent and maintain selection" })
map("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })
map("x", "<bs>", [["_d]], { desc = "Delete without yanking" })
map({ "n", "x", "o" }, "H", "^", { desc = "Beginning of line" })
map({ "n", "x", "o" }, "L", "g_", { desc = "End of line" })
map("x", "il", "^og_", { desc = "Select line without whitespace" })
map("o", "il", "<cmd>normal vil<cr>", { desc = "Operate line" })
map("x", "y", "ygv<esc>", { desc = "Cursor-in-place copy" })
map("x", "Q", "<cmd>norm @q<CR>", { desc = "Run macro 'q' on selection" })
map("n", "y<c-g>", function()
    vim.fn.setreg("+", vim.fn.expand("%:."))
end, { desc = "Yank relative file path to clipboard" })
map({ "n", "x", "o" }, "M", "%", { remap = true, desc = "Matchit" })
map("n", "<leader>w", "<cmd>update<cr>", { desc = "Save File" })
map("n", "<leader><c-l>", "<Cmd>nohlsearch|diffupdate|normal! <C-L><CR>", { desc = "Redraw" })
map("n", "<leader><c-o>", "<cmd>pop<cr>", { desc = "Pop off tag stack" })
map("x", "J", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down", silent = true })
map("x", "K", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up", silent = true })
map("n", "C", '"_C', { desc = "Change into void" })
map({ "x", "n" }, "c", '"_c', { desc = "change into void" })
map("n", "*", "*``", { desc = "Same pos search" })
map("x", "v", "an", { desc = "Incremental Selection", remap = true })
map("x", "<c-r>", "in", { desc = "Reduce Selection", remap = true })

local next_yank, prev_yank = rep.pair(function()
    require("custom.ying").cycle(1)
end, function()
    require("custom.ying").cycle(-1)
end)

map({ "n", "x" }, "p", function()
    require("custom.ying").put("p")
end, { desc = "Put after" })
map({ "n", "x" }, "P", function()
    require("custom.ying").put("P")
end, { desc = "Put before" })
map("n", "]y", next_yank, { desc = "Next Yank History" })
map("n", "[y", prev_yank, { desc = "Prev Yank History" })
map("n", "<leader>sy", function()
    require("custom.ying").picker()
end, { desc = "Yank History Picker" })

if vim.g.vscode then
    return
end

local next_buffer, prev_buffer = rep.pair(function()
    pcall(vim.cmd.bnext, { count = vim.v.count1 })
end, function()
    pcall(vim.cmd.bprevious, { count = vim.v.count1 })
end)
local next_ll, prev_ll = rep.pair(function()
    pcall(vim.cmd.lnext, { count = vim.v.count1 })
end, function()
    pcall(vim.cmd.lprevious, { count = vim.v.count1 })
end)

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
map("n", "<leader>bb", "<c-^>", { desc = "Buffer Back" })
map("n", "]b", next_buffer, { desc = "Next Buffer" })
map("n", "[b", prev_buffer, { desc = "Prev Buffer" })
map("n", "]l", next_ll, { desc = "Next Location List Item" })
map("n", "[l", prev_ll, { desc = "Prev Location List Item" })

-- Terminal
map("t", "<a-n>", "<c-\\><c-n>", { desc = "Terminal escape" })

-- Tabs and windows
map("n", "<a-]>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<a-[>", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
map("n", "<a-s-]>", "<cmd>tabmove+<cr>", { desc = "Move Tab Right" })
map("n", "<a-s-[>", "<cmd>tabmove-<cr>", { desc = "Move Tab Left" })
for i = 1, 5 do
    map("n", "<leader>" .. i, "<cmd>tabnext " .. i .. "<cr>", { desc = "Go to Tab " .. i })
end
map("n", "<leader>\\", "<cmd>vs<cr>", { desc = "New Vertical Split" })
map("n", "<leader><cr>", "<cmd>sp<cr>", { desc = "New Horizontal Split" })
map("n", "<leader>tt", "<cmd>tabnew | term<cr>", { desc = "Tab terminal" })
map("n", "<c-t>", "<cmd>tab split<cr>", { desc = "Open window in new tab" })
map("n", "<c-s-w>", "<cmd>tabclose<CR>", { desc = "Close tab" })
map("n", "<leader>to", "<cmd>tabonly<cr>", { desc = "Close other tabs" })
map("n", "<a-s-,>", "<c-w>3<", { desc = "Resize window left" })
map("n", "<a-s-.>", "<c-w>3>", { desc = "Resize window right" })
map("n", "+", "3<C-W>+", { desc = "Resize window up" })
map("n", "_", "3<C-W>-", { desc = "Resize window down" })

-- Editing
map("c", "<C-a>", "<Home>", { desc = "Beginning of line" })
map(
    "x",
    "<C-h>",
    [[<esc>:%s/\V<C-R>=escape(getregion(getpos("'<"), getpos("'>"))[0], '/\')<CR>//gI<Left><Left><Left>]],
    { desc = "Search and replace selection" }
)
map("c", "<C-h>", function()
    if vim.fn.getcmdtype() ~= "/" then
        return "<C-h>"
    end
    local word = vim.fn.expand("<cword>")
    return "<C-c>:%s/\\<" .. word .. "\\>//gI" .. ("<Left>"):rep(3)
end, { expr = true, desc = "Search and replace word" })
map("c", "<a-f>", "<S-Right>", { desc = "Forward a word" })
map("c", "<a-b>", "<S-Left>", { desc = "Backward a word" })
map("s", "<BS>", "<C-o>s", { desc = "Remove Snippet Placeholder" })
map({ "i", "x", "n", "s" }, "<D-s>", "<esc><cmd>update<cr>", { desc = "Save File" })
map("i", "<C-CR>", "<C-o>o", { desc = "Insert line below" })
map("n", "<C-CR>", "]<space>", { remap = true, desc = "New line below" })
map("i", "<C-;>", "<C-o>$;", { desc = "Append semicolon at EOL" })
map({ "i", "c" }, "<a-bs>", "<c-w>", { desc = "Delete word" })

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

map("n", "z<space>", "<cmd>%foldclose<CR>", { desc = "Close toplevel folds" })
map("n", "dm", ":execute 'delmarks '.nr2char(getchar())<cr>", { silent = true })
