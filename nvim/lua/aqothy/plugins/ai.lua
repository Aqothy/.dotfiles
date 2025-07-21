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
            vim.g.copilot_no_tab_map = true
            vim.g.copilot_filetypes = {
                ["*"] = true,
                dotenv = false,
            }
        end,
        config = function()
            vim.keymap.set("i", "<M-a>", 'copilot#Accept("")', {
                expr = true,
                replace_keycodes = false,
                silent = true,
                desc = "Accept suggestions",
            })
        end,
    },
}
