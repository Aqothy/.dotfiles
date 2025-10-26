require("aqothy.config.options")
vim.filetype.add({
    filename = {
        [".env"] = "dotenv",
    },
    pattern = {
        [".*/kitty/.+%.conf"] = "kitty",
        ["%.env%.[%w_.-]+"] = "dotenv",
    },
})

require("aqothy.config")

require("aqothy.config.autocmds")
require("aqothy.config.keymaps")
require("aqothy.config.commands")
require("aqothy.config.statusline")
require("aqothy.config.tabline")

require("vim._extui").enable({})

local git_dir = vim.fn.expand("~/.dotfiles")
local work_tree = vim.fn.expand("~")
local config_home = vim.env.XDG_CONFIG_HOME or vim.fn.expand("~/.config")
local cwd = vim.fn.getcwd()

if vim.startswith(cwd, config_home) then
    vim.env.GIT_DIR = git_dir
    vim.env.GIT_WORK_TREE = work_tree
end
