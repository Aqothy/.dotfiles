vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.updatetime = 50

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.showmode = false

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.termguicolors = true

vim.opt.clipboard = "unnamedplus"

vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.signcolumn = "yes"
--vim.opt.colorcolumn = "80"
vim.opt.isfname:append("@-@")

--vim.opt.fileencoding = "utf-8"

--local CleanSpaceGroup = augroup('CleanSpace', {})
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

-- already handled by lsp format
--autocmd({ "BufWritePre" }, {
--    group = CleanSpaceGroup,
--    pattern = "*",
--    command = [[%s/\s\+$//e]],
--})

--vim.g.netrw_banner = 0
--vim.g.netrw_browse_split = 4
--vim.g.netrw_liststyle = 3
--vim.g.netrw_winsize = -28
--vim.g.netrw_browsex_viewer = "open -a safari"

--vim.opt.spelllang = 'en_us'
--vim.opt.spell = true

--vim.opt.foldcolumn = '1'
--vim.opt.foldenable = true
--vim.opt.foldexpr = 'v:lua.vim.lsp.foldexpr()'
--vim.opt.foldlevel = 99
--vim.opt.foldlevelstart = 99
--vim.opt.foldmethod = 'expr'
