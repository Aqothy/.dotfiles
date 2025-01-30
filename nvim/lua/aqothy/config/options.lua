vim.g.projects_dir = vim.env.HOME .. "/Code/Personal"
vim.g.XDG_CONFIG_HOME = vim.env.HOME .. "/.config"

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.autoindent = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.updatetime = 300

vim.opt.splitright = true
vim.opt.splitkeep = "screen"
vim.opt.splitbelow = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.termguicolors = true

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

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

vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.showtabline = 0

vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 20
vim.g.netrw_browsex_viewer = "open -a safari"

vim.opt.spelllang = "en_us"
--vim.opt.spell = true

vim.opt.pumheight = 10 -- Maximum number of entries in a popup
vim.opt.completeopt = { "menu", "menuone", "noselect" }

vim.opt.undolevels = 10000

vim.opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
vim.opt.splitkeep = "screen" -- no shift and screen stays stable when splitting
vim.opt.grepprg = "rg --vimgrep"
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.confirm = true
vim.opt.laststatus = 3
-- vim.opt.inccommand = "split"
vim.opt.wildmode = "longest:full,full"
vim.opt.backspace = { "start", "eol", "indent" }
vim.opt.ruler = false -- already handled by statusline
vim.g.markdown_recommended_style = 0
vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })

-- command line
vim.opt.cmdheight = 0
vim.opt.showcmd = false

-- copilot
vim.g.copilot_enabled = 1

-- format
vim.g.autoformat = true

-- folds
vim.opt.fillchars = { eob = " " }

vim.opt.foldcolumn = "0" -- 0 since snacks handles it
vim.o.foldenable = true
vim.o.foldexpr = "v:lua.vim.lsp.foldexpr()"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldmethod = "expr"
vim.o.foldtext = ""

-- Disable health checks for these providers.
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

vim.g.copilot_no_tab_map = true

vim.opt.formatexpr = "v:lua.require'conform'.formatexpr()"

vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

-- animations
-- vim.g.snacks_animate = false
