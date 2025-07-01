vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Disable health checks for these providers.
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 0
vim.g.netrw_liststyle = 3

local opt = vim.opt

opt.number = true
opt.relativenumber = true

-- indentation
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.breakindent = true

opt.swapfile = false
opt.writebackup = false
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 300
opt.list = true
opt.listchars = {
    tab = "▏ ",
    trail = "·",
    extends = "»",
    precedes = "«",
    nbsp = "⦸",
}

opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.inccommand = "split"

opt.ignorecase = true
opt.infercase = true
opt.smartcase = true

-- Sync clipboard between OS and Neovim.
-- Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function()
    opt.clipboard = "unnamedplus"

    if vim.env.SSH_TTY ~= nil then
        local osc52 = require("vim.ui.clipboard.osc52")
        vim.g.clipboard = {
            name = "OSC 52",
            copy = {
                ["+"] = osc52.copy("+"),
                ["*"] = osc52.copy("*"),
            },
            paste = {
                ["+"] = osc52.paste("+"),
                ["*"] = osc52.paste("*"),
            },
        }
    end
end)

opt.mouse = "a"

-- completion
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.completeopt = { "menuone", "noinsert", "fuzzy", "popup" }
opt.completeitemalign = { "kind", "abbr", "menu" }
opt.wildignore:append({ ".DS_Store" })
opt.wildignorecase = true
opt.wildmode = { "longest:full", "full" }
opt.wildoptions:append({ "fuzzy" })

opt.cursorline = false
opt.laststatus = 3
opt.signcolumn = "yes"
opt.winborder = "rounded"
opt.diffopt = { "internal", "filler", "closeoff", "inline:none", "indent-heuristic", "algorithm:histogram" }
opt.termguicolors = true
-- opt.showbreak = "↪"
opt.scrolloff = 8
-- opt.sidescrolloff = 8
-- opt.colorcolumn = "80"

opt.fileencoding = "utf-8"

-- opt.spell = true

if vim.fn.executable("rg") == 1 then
    opt.grepprg = "rg --vimgrep"
    opt.grepformat = "%f:%l:%c:%m"
end

opt.confirm = true
opt.shortmess:append({ W = true, I = false, c = true, C = true, A = true, a = true })
opt.ruler = false -- already handled by statusline
opt.jumpoptions = "stack"

-- command line
opt.showcmd = false
opt.showmode = false

-- folds
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldtext = ""
opt.fillchars = { eob = " ", foldopen = "", foldclose = "", fold = " ", foldsep = " ", diff = "╱" }
-- opt.statuscolumn = "%!v:lua.require'aqothy.config.statuscolumn'.render()"
-- opt.numberwidth = 5 -- 5 instead of 4 to make space for folds

opt.whichwrap:append("h,l") -- allow move to next line with the
opt.wrap = true
opt.linebreak = true
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode

-- opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "winpos", "help", "globals", "folds", "terminal" }

opt.background = "dark"
