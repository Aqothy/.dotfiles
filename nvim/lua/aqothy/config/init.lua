local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- custom lazyfile event so no need to write these 3 events everytime
local Event = require("lazy.core.handler.event")
local lazy_file_events = { "BufReadPost", "BufNewFile", "BufWritePre" }
Event.mappings.LazyFile = { id = "LazyFile", event = lazy_file_events }
Event.mappings["User LazyFile"] = Event.mappings.LazyFile

local is_vscode = vim.g.vscode

local disabled_plugins = {
    "gzip",
    "tarPlugin",
    "tohtml",
    "tutor",
    "zipPlugin",
}

local lazy_spec = {
    import = "aqothy.plugins",
}

if is_vscode then
    vim.list_extend(disabled_plugins, { "matchit", "matchparen", "netrwPlugin" })
    lazy_spec = {
        import = "aqothy.vscode.plugins",
    }
end

-- Setup lazy.nvim
require("lazy").setup({
    spec = lazy_spec,
    install = { colorscheme = { "gruvbox" } },
    defaults = {
        lazy = false,
        version = false, -- always use the latest git commit
        -- version = "*", -- try installing the latest stable version for plugins that support semver
    },
    -- automatically check for plugin updates
    checker = { enabled = false },
    change_detection = { notify = false },
    rocks = {
        enabled = false,
    },
    performance = {
        rtp = {
            -- disable some rtp plugins
            disabled_plugins = disabled_plugins,
        },
    },
})
