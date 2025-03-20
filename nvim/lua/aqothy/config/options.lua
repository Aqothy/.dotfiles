vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Disable health checks for these providers.
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
vim.g.markdown_recommended_style = 0

vim.g.projects_dir = vim.env.HOME .. "/Code"
vim.g.dotfiles = vim.env.HOME .. "/.config"

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.breakindent = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.undolevels = 1000
vim.opt.updatetime = 300
vim.opt.autowrite = true

vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.splitkeep = "screen" -- no shift and screen stays stable when splitting
vim.opt.inccommand = "split"

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.termguicolors = true

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

vim.opt.mouse = "a"

-- completion
vim.opt.pumheight = 10 -- Maximum number of entries in a popup
vim.opt.completeopt = { "menu", "menuone", "noinsert" }
vim.opt.wildignore:append({ ".DS_Store" })
vim.opt.wildignorecase = true
vim.opt.wildmode = { "longest:full", "full" }

-- ui
-- vim.opt.cursorline = true
-- vim.opt.showtabline = 0
vim.opt.laststatus = 3
vim.opt.fillchars = { eob = " ", foldopen = "", foldclose = "", fold = " ", foldsep = " ", diff = "╱" }
vim.opt.signcolumn = "yes"
vim.opt.showbreak = "↪ "
vim.opt.formatexpr = "v:lua.require'conform'.formatexpr()"
vim.opt.conceallevel = 2
vim.opt.formatoptions:remove("o")
vim.g.snacks_animate = false

vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 25

vim.opt.spelllang = "en_us"
-- vim.opt.spell = true

vim.opt.grepprg = "rg --vimgrep"
vim.opt.grepformat = "%f:%l:%c:%m"

vim.opt.confirm = true
vim.opt.shortmess:append({ W = true, I = false, c = true, C = true })
vim.opt.ruler = false -- already handled by statusline
vim.opt.jumpoptions = { "stack", "view", "clean" }

-- command line
vim.opt.showcmd = false
vim.opt.showmode = false

-- folds
vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldtext = ""
vim.opt.foldexpr = "v:lua.require'aqothy.config.utils'.foldexpr()"
vim.opt.foldmethod = "expr"

vim.opt.sessionoptions = { "curdir", "folds", "help", "winsize", "winpos", "terminal" }

vim.opt.whichwrap:append("<,>,[,],h,l") -- allow move to next line with the
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode

vim.opt.background = "light"
