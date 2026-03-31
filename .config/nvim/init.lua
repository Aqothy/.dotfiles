require("config.options")
vim.treesitter.language.register("bash", { "kitty", "zsh" })

require("config")

require("config.keymaps")
require("config.commands")
require("config.autocmds")

if not vim.g.vscode then
    vim.schedule(function()
        require("custom.tabline").setup()
        require("custom.alternate").setup()
        require("vim._core.ui2").enable({ msg = { target = "msg", timeout = 3000 } })
        require("vim._core.ui2").enable({})
    end)
    require("custom.statusline").setup()
    require("custom.statuscolumn").setup()
    require("custom.session").setup({
        allowed_dirs = {
            "~/Code/Personal",
        },
        hooks = {
            before_save = function()
                local ok, dv_lib = pcall(require, "diffview.lib")
                if ok and dv_lib and dv_lib.views then
                    for _, view in pairs(dv_lib.views) do
                        view:close()
                    end
                end
            end,
        },
    })
end

require("custom.toggler").setup()
