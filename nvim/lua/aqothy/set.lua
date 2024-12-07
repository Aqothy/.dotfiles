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

vim.opt.hlsearch = false
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

local filetype_settings = {
  ["javascript"] = 2,
  ["typescript"] = 2,
  ["typescriptreact"] = 2,
  ["javascriptreact"] = 2,
  ["go"] = 2,
  ["css"] = 2,
  ["html"] = 2,
  ["json"] = 2,
  ["yaml"] = 2,
  ["lua"] = 2,
}

vim.api.nvim_create_autocmd("FileType", {
  callback = function(params)
    local size = filetype_settings[params.match]
    if size then
      vim.opt_local.tabstop = size
      vim.opt_local.shiftwidth = size
      vim.opt_local.softtabstop = size
      vim.opt_local.expandtab = true
    end
  end,
})

--vim.g.netrw_banner = 0
--vim.g.netrw_browse_split = 4
--vim.g.netrw_liststyle = 3
--vim.g.netrw_winsize = -28
--vim.g.netrw_browsex_viewer = "open -a safari"

--vim.opt.spelllang = 'en_us'
--vim.opt.spell = true

--vim.opt.signcolumn = "yes"

--vim.opt.foldcolumn = '1'
--vim.opt.foldenable = true
--vim.opt.foldexpr = 'v:lua.vim.lsp.foldexpr()'
--vim.opt.foldlevel = 99
--vim.opt.foldlevelstart = 99
--vim.opt.foldmethod = 'expr'
