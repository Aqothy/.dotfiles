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
            vim.g.copilot_node_command = "~/.local/bin/npc"
            vim.g.copilot_no_tab_map = true
            vim.g.copilot_filetypes = {
                ["*"] = true,
                dotenv = false,
            }
        end,
        config = function()
            vim.keymap.set("i", "<C-k>", 'copilot#Accept("")', {
                expr = true,
                replace_keycodes = false,
                silent = true,
                desc = "Accept suggestions",
            })
        end,
    },
}
