return {
    {
        "github/copilot.vim",
        event = { "BufReadPre", "BufNewFile", "BufWritePre" },
        cmd = "Copilot",
        init = function()
            vim.g.copilot_lsp_settings = {
                telemetry = {
                    telemetryLevel = "off",
                },
            }
            vim.g.copilot_proxy_strict_ssl = false
            vim.g.copilot_node_command = "~/.local/bin/npc"
            vim.g.copilot_filetypes = {
                ["*"] = true,
                dotenv = false,
            }
        end,
    },
}
