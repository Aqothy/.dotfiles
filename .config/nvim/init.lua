require("config.options")
require("config")
vim.schedule(function()
    require("config.keymaps")
    require("config.commands")
end)
require("config.autocmds")

if not vim.g.vscode then
    vim.schedule(function()
        require("custom.tabline").setup()
        require("custom.alternate").setup()
        require("custom.marks").setup()
        require("custom.folds").setup()
        require("custom.markdown_preview").setup()
        require("custom.agents").setup()
        require("vim._core.ui2").enable({ msg = { target = "msg", msg = { timeout = 3000 } } })
    end)
    require("custom.statusline").setup()
    require("custom.session").setup({
        allowed_dirs = {
            "~/Code/Personal",
        },
        hooks = {
            before_save = function()
                local ok_agents, agents = pcall(require, "custom.agents")
                if ok_agents and agents.stop_all then
                    agents.stop_all()
                end

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

vim.schedule(function()
    require("custom.toggler").setup()
    require("custom.ying").setup()
end)
