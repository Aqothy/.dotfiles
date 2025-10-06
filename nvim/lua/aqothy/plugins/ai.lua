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
        end,
        config = function()
            vim.keymap.set("i", "<C-l>", 'copilot#Accept("\\<C-l>")', {
                expr = true,
                replace_keycodes = false,
                desc = "Accept Copilot Suggestion",
            })
        end,
    },
    {

        "folke/sidekick.nvim",
        opts = {
            signs = {
                enabled = false,
            },
        },
        event = "VeryLazy",
        -- stylua: ignore
        keys = {
            {
                "<Tab>",
                function()
                    if not require("sidekick").nes_jump_or_apply() then
                        return "<Tab>"
                    end
                end,
                expr = true,
                desc = "Goto/Apply Next Edit Suggestion",
            },
            {
                "<leader>aa",
                function() require("sidekick.cli").toggle() end,
                desc = "Sidekick Toggle CLI",
            },
            {
                "<c-.>",
                function() require("sidekick.cli").focus() end,
                mode = { "n", "x", "i", "t" },
                desc = "Sidekick Switch Focus",
            },
        },
    },
}
