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

vim.opt.updatetime = 300

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.showmode = false

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.termguicolors = true

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.signcolumn = "yes"
-- vim.opt.colorcolumn = "80"
vim.opt.isfname:append("@-@")

vim.opt.mouse = "a"
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.linebreak = true

-- Show which line your cursor is on
vim.opt.cursorline = true

vim.opt.fileencoding = "utf-8"
vim.opt.showcmd = false
vim.opt.showtabline = 0

--vim.g.netrw_banner = 0
--vim.g.netrw_browse_split = 4
--vim.g.netrw_liststyle = 3
--vim.g.netrw_winsize = -28
--vim.g.netrw_browsex_viewer = "open -a safari"

vim.opt.spelllang = 'en_us'
--vim.opt.spell = true

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = "v:lua.vim.treesitter.foldtext()"
vim.opt.foldenable = true     -- Enable folding by default
vim.opt.foldlevel = 99        -- Start with all folds open
vim.opt.foldcolumn = '1'
vim.opt.foldlevelstart = 99

vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.conceallevel = 2
vim.opt.confirm = true

vim.opt.fillchars = {
  foldopen = "",
  foldclose = "",
  diff = "╱",
  eob = " ",
}

vim.opt.undolevels = 10000
vim.opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]
vim.opt.laststatus = 3

vim.opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
vim.opt.splitkeep = "screen"
vim.opt.grepprg = "rg --vimgrep"
