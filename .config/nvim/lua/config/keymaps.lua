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

-- Tabs
map("n", "<c-]>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<c-[>", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
for i = 1, 9 do
    map("n", "<leader>" .. i, "<cmd>tabnext " .. i .. "<cr>", { desc = "Go to Tab " .. i })
end
map("t", "<c-[>", "<c-\\><c-n>", { desc = "Esc Terminal" })
map("t", "<esc>", function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", false)
end, { desc = "Feed esc" })
map("n", "<leader>\\", "<cmd>vs<cr>", { desc = "New Vertical Split" })
map("n", "<leader><cr>", "<cmd>sp<cr>", { desc = "New Horizontal Split" })
map("n", "<a-]>", "<Cmd>tabmove +1<CR>", { desc = "Move tab right" })
map("n", "<a-[>", "<Cmd>tabmove -1<CR>", { desc = "Move tab left" })
map("n", "<leader>tt", "<cmd>tabnew | term<cr>", { desc = "Tab terminal" })
map("n", "<M-t>", "<cmd>tab split<cr>", { desc = "Open window in new tab" })
map("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close tab" })
map("n", "<leader>to", "<cmd>tabonly<cr>", { desc = "Close other tabs" })
map("n", "cdl", "<cmd>lcd %:h | pwd<cr>", { desc = "Change directory to current file's directory" })
map("n", "cdu", "<cmd>lcd .. | pwd<cr>", { desc = "Change directory to parent directory" })
map("n", "cd-", "<cmd>lcd - | pwd<cr>", { desc = "Change directory to previous directory" })

-- Editing
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
map("n", "<c-q>", function()
    local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
    if not success and err then
        vim.notify(err, vim.log.levels.ERROR)
    end
end, { desc = "Toggle qf" })
map("n", "<localleader>q", function()
    local success, err = pcall(vim.fn.getloclist(0, { all = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
    if not success and err then
        vim.notify(err, vim.log.levels.ERROR)
    end
end, { desc = "Toggle loclist" })
map("n", "y<c-g>", function()
    vim.fn.setreg("+", vim.fn.expand("%:."))
end, { desc = "Yank relative file path to clipboard" })
map("n", "<M-r>", "<Cmd>nohlsearch|diffupdate|normal! <C-L><CR>", { desc = "Redraw" })
map("n", "<M-z>", function()
    vim.wo.wrap = not vim.wo.wrap
end, { desc = "Toggle word wrap" })

map({ "i", "x", "n", "s" }, "<D-s>", "<esc><cmd>update<cr>", { desc = "Save File" })
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
map("n", "<M-d>", vim.diagnostic.open_float, { desc = "Diagnostic Float" })
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
