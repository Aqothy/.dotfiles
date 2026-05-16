return {
    {
        "github/copilot.vim",
        cmd = "Copilot",
        init = function()
            vim.g.copilot_filetypes = {
                ["*"] = true,
                env = false,
            }
            vim.g.copilot_version = false
            vim.g.copilot_node_command = "/Users/aqothy/.local/bin/node"
        end,
    },
}
