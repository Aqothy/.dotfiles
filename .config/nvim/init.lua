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
    vim.schedule(function()
        require("custom.statusline").setup()
        require("custom.tabline").setup()
        require("custom.alternate").setup()
        require("vim._core.ui2").enable({ msg = { target = "msg", timeout = 3000 } })
    end)
    require("custom.session").setup({
        allowed_dirs = {
            "~/Code/Personal",
        },
        auto_start = false,
    })
end

require("custom.toggler").setup()
