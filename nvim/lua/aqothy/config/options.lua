vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Disable health checks for these providers.
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

vim.g.netrw_banner = 0

local opt = vim.opt

opt.number = true
opt.relativenumber = true

-- indentation
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4

opt.swapfile = false
opt.writebackup = false
opt.undofile = true
opt.updatetime = 300

opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.inccommand = "split"

opt.ignorecase = true
opt.smartcase = true

-- Sync clipboard between OS and Neovim.
-- Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function()
    opt.clipboard = "unnamedplus"
end)

opt.mouse = "a"

-- completion
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.completeopt = { "menuone", "noinsert", "fuzzy", "popup" }
opt.completeitemalign = { "kind", "abbr", "menu" }
opt.wildignore:append({ ".DS_Store" })

opt.signcolumn = "yes"
opt.winborder = "rounded"
opt.diffopt = { "internal", "filler", "closeoff", "inline:none", "indent-heuristic", "algorithm:histogram" }
opt.termguicolors = true
opt.scrolloff = 8

opt.fileencoding = "utf-8"

if vim.fn.executable("rg") == 1 then
    opt.grepprg = "rg --vimgrep"
    opt.grepformat = "%f:%l:%c:%m"
end

opt.confirm = true
opt.shortmess:append({ W = true, c = true, C = true, a = true })
opt.jumpoptions = { "stack", "view" }

-- command line
opt.showcmd = false

opt.fillchars = { eob = " ", diff = "╱" }

opt.whichwrap:append("h,l") -- allow move to next line with the
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode

opt.background = "dark"
