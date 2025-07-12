return {
    {
        "github/copilot.vim",
        event = "BufReadPost",
        cmd = "Copilot",
        init = function()
            vim.g.copilot_lsp_settings = {
                telemetry = {
                    telemetryLevel = "off",
                },
            }
            vim.g.copilot_settings = { selectedCompletionModel = "gpt-4o-copilot" }
            vim.g.copilot_filetypes = {
                ["*"] = true,
                dotenv = false,
            }
        end,
    },
}
