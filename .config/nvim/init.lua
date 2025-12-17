vim.loader.enable()

require("config.options")
vim.filetype.add({
    filename = {
        [".env"] = "dotenv",
    },
    pattern = {
        ["%.env%.[%w_.-]+"] = "dotenv",
    },
})
vim.treesitter.language.register("bash", { "kitty", "dotenv", "zsh" })

require("config")

require("config.keymaps")
require("config.commands")
require("config.autocmds")

if not vim.g.vscode then
    require("custom.statusline")
    require("custom.tabline")
    require("custom.session").setup({
        allowed_dirs = {
            "~/Code/Personal",
        },
    })
    require("custom.alternate").setup()

    require("vim._extui").enable({})
end
