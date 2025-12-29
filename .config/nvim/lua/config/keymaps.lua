local map = vim.keymap.set

-- "Whole Buffer" text-object:
map("x", "ig", "gg^oG$", { desc = "Select whole buffer" })
map("o", "ig", "<cmd>normal vig<cr>", { desc = "Operate whole buffer" })

map("x", ">", ">gv", { desc = "Indent and maintain selection" })
map("x", "<", "<gv", { desc = "Outdent and maintain selection" })
map("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })
map({ "n", "x", "o" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })
map({ "n", "x", "o" }, "H", "^", { desc = "Beginning of line" })
map({ "n", "x", "o" }, "L", "$", { desc = "End of line" })
map("x", "iL", "^og_", { desc = "Select line without whitespace" })
map("o", "iL", "<cmd>normal viL<cr>", { desc = "Operate line" })
map("x", "y", "ygv<esc>", { desc = "Cursor-in-place copy" })
map("n", "g/", ":%s/\\<<c-r><c-w>\\>/<c-r><c-w>/gIc<left><left><left><left>", { desc = "Replace word in buffer" })
map("x", "g/", '"sy:%s/\\V<C-r>s/<C-r>s/gIc<left><left><left><left>', { desc = "Replace visual word" })
map("n", "g.", "*``cgn", { desc = "Search and replace word under cursor" })
map(
    "x",
    "g.",
    [["sy:let @/ = '\V' . substitute(escape(@s, '/\'), '\n', '\\n', 'g')<CR>:set hls<CR>cgn]],
    { desc = "Search & Replace selection" }
)
map("x", "Q", "<cmd>norm @q<CR>", { desc = "Run macro 'q' on selection" })
map("c", "<c-j>", [[\(.*\)]], { desc = "Fighting Kirby!" })
map("n", "y<c-g>", function()
    vim.fn.setreg("+", vim.fn.expand("%:."))
end, { desc = "Yank relative file path to clipboard" })
map({ "n", "x", "o" }, "M", "%", { remap = true, desc = "Matchit" })
map("n", "<leader>w", "<esc><cmd>update<cr>", { desc = "Save File" })
map("n", "<leader><c-l>", "<Cmd>nohlsearch|diffupdate|normal! <C-L><CR>", { desc = "Redraw" })

if vim.g.vscode then
    return
end

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
map("n", "<s-tab>", "<c-^>", { desc = "Alternate buffer" })
map("n", "<M-s-,>", "<c-w>3<", { desc = "Resize window left" })
map("n", "<M-s-.>", "<c-w>3>", { desc = "Resize window right" })
map("n", "<M-s-->", "3<C-W>+", { desc = "Resize window up" })
map("n", "<M-s-=>", "3<C-W>-", { desc = "Resize window down" })
map("n", "<A-down>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-up>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-down>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-up>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("x", "<A-down>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("x", "<A-up>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- Terminal
map("t", "<c-q>", "<c-\\><c-n>", { desc = "Esc Terminal" })
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to Left Window" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to Lower Window" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to Upper Window" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to Right Window" })
map("t", "<C-x><C-l>", "<C-l>", { desc = "Send Original Ctrl-l (Clear)" })
map("t", "<C-x><C-k>", "<C-k>", { desc = "Send Original Ctrl-k (Kill Line)" })

-- Tabs and windows
map("n", "<c-]>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<c-[>", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
map("n", "<leader>\\", "<cmd>vs<cr>", { desc = "New Vertical Split" })
map("n", "<leader><cr>", "<cmd>sp<cr>", { desc = "New Horizontal Split" })
map("n", "<a-]>", "<Cmd>tabmove +1<CR>", { desc = "Move tab right" })
map("n", "<a-[>", "<Cmd>tabmove -1<CR>", { desc = "Move tab left" })
map("n", "<leader>tt", "<cmd>tabnew | term<cr>", { desc = "Tab terminal" })
map("n", "<leader>ts", "<cmd>tab split<cr>", { desc = "Open window in new tab" })
map("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close tab" })
map("n", "<leader>to", "<cmd>tabonly<cr>", { desc = "Close other tabs" })
map("n", "cdl", "<cmd>lcd %:h | pwd<cr>", { desc = "Change directory to current file's directory" })
map("n", "cdu", "<cmd>lcd .. | pwd<cr>", { desc = "Change directory to parent directory" })
map("n", "cd-", "<cmd>lcd - | pwd<cr>", { desc = "Change directory to previous directory" })

-- Editing
map("i", "<C-b>", "<Left>", { desc = "Backward char" })
map("c", "<C-b>", "<Left>", { desc = "Backward char" })
map("i", "<C-f>", "<Right>", { desc = "Forward char" })
map("c", "<C-f>", "<Right>", { desc = "Forward char" })
map("s", "<BS>", "<C-o>s", { desc = "Remove Snippet Placeholder" })
map("i", "<C-A>", "<C-O>^", { desc = "Beginning of line" })
map("c", "<C-A>", "<Home>", { desc = "Beginning of line" })
map("i", "<C-E>", "<End>", { desc = "End of line" })
map("i", "<C-;>", "<End>", { desc = "End of line" })
map("c", "<C-E>", "<End>", { desc = "End of line" })
map("i", "<M-f>", "<S-Right>", { desc = "Forward a word" })
map("c", "<M-f>", "<S-Right>", { desc = "Forward a word" })
map("i", "<M-b>", "<S-Left>", { desc = "Backward a word" })
map("c", "<M-b>", "<S-Left>", { desc = "Backward a word" })
map("i", "<M-d>", "<C-O>dw", { desc = "Delete word forward" })
map("c", "<M-d>", "<S-Right><C-W>", { desc = "Delete word forward" })
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

-- utils
map("n", "<localleader>x", "<cmd>source %<cr>", { desc = "Source file" })
map("n", "y<c-g>", function()
    vim.fn.setreg("+", vim.fn.expand("%:."))
end, { desc = "Yank relative file path to clipboard" })

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
