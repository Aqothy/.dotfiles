local g = vim.g
g.mapleader = vim.keycode("<space>")
g.maplocalleader = vim.keycode("\\")

-- Disable health checks for these providers.
g.loaded_python3_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0
g.loaded_node_provider = 0

local opt = vim.opt

opt.number = true
opt.relativenumber = true

-- indentation
opt.expandtab = true
opt.shiftwidth = 0
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftround = true
opt.smartindent = true
opt.breakindent = true
opt.linebreak = true

opt.swapfile = false
opt.writebackup = false
opt.undofile = true
opt.updatetime = 200
opt.history = 100
opt.lazyredraw = true

opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"

opt.ignorecase = true
opt.smartcase = true

-- Sync clipboard between OS and Neovim.
-- Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function()
    opt.clipboard = "unnamedplus"
end)

opt.mouse = "a"

-- completion
opt.pumheight = 10
opt.completeopt = { "menuone", "noinsert", "fuzzy", "popup" }
opt.wildignore:append({ ".DS_Store" })
opt.wildoptions:append({ "fuzzy" })

opt.signcolumn = "yes"
opt.winborder = "rounded"
opt.diffopt = { "internal", "filler", "closeoff", "inline:char", "indent-heuristic" }
opt.termguicolors = true
opt.scrolloff = 8
opt.whichwrap:append("h,l")
opt.showcmd = false
opt.fillchars = { eob = " ", diff = "╱" }
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.background = "dark"
opt.foldlevel = 99
opt.cursorline = true
opt.list = true
opt.listchars = {
    tab = "▏ ",
    trail = "·",
}

opt.fileencoding = "utf-8"

if vim.fn.executable("rg") == 1 then
    opt.grepprg = 'rg --vimgrep --smart-case --color=never -g "!.git" --hidden'
end

opt.confirm = true
opt.shortmess:append({ W = true, I = true, c = true, C = true, a = true })
opt.jumpoptions = { "stack", "view" }
opt.sessionoptions = { "curdir", "tabpages", "winsize", "terminal" }
