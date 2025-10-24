return {
    {
        "github/copilot.vim",
        init = function()
            vim.g.copilot_lsp_settings = {
                telemetry = {
                    telemetryLevel = "off",
                },
            }
            vim.g.copilot_no_tab_map = true
            vim.g.copilot_proxy_strict_ssl = false
            vim.g.copilot_node_command = "/Users/aqothy/.local/bin/npc"
            vim.g.copilot_filetypes = {
                ["*"] = true,
                dotenv = false,
            }
            local copilot_enabled = true
            vim.keymap.set("n", "<leader>tc", function()
                if copilot_enabled then
                    local client = vim.lsp.get_clients({ name = "GitHub Copilot" })[1]
                    if client then
                        vim.lsp.stop_client(client.id)
                    end
                    vim.notify("Copilot disabled")
                else
                    vim.cmd("Copilot restart")
                    vim.notify("Copilot enabled")
                end
                copilot_enabled = not copilot_enabled
            end, { desc = "Toggle Copilot" })
        end,
    },
    {
        "folke/sidekick.nvim",
        opts = {
            signs = {
                enabled = false,
            },
            cli = {
                win = {
                    layout = "float",
                    wo = {
                        scrolloff = 8,
                    },
                    float = {
                        width = vim.o.columns,
                        height = vim.o.lines,
                        border = "none",
                    },
                },
            },
        },
        event = "VeryLazy",
        -- stylua: ignore
        keys = {
            {
                "<tab>",
                function()
                    if not require("sidekick").nes_jump_or_apply() then
                        return "<tab>"
                    end
                end,
                expr = true,
                desc = "Goto/Apply Next Edit Suggestion",
            },
            {
                "<c-.>",
                function() require("sidekick.cli").toggle() end,
                desc = "Sidekick Toggle",
                mode = { "n", "t", "i" },
            },
            {
                "<leader>as",
                function() require("sidekick.cli").select() end,
                desc = "Select CLI",
            },
            {
                "<leader>ac",
                function() require("sidekick.cli").close() end,
                desc = "Close a CLI Session",
            },
        },
    },
}
