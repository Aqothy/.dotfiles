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

require("config")

if not vim.g.vscode then
    require("config.keymaps")
    require("config.commands")
    require("config.autocmds")
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
