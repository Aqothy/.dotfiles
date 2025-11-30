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
            vim.g.copilot_filetypes = {
                ["*"] = true,
                dotenv = false,
            }
            vim.keymap.set("i", "<s-tab>", 'copilot#Accept("\\<s-tab>")', {
                expr = true,
                replace_keycodes = false,
                desc = "Accept Copilot Suggestion",
            })
            vim.keymap.set({ "i", "s" }, "<c-c>", function()
                vim.fn["copilot#Dismiss"]()
                require("sidekick.nes").clear()
            end, {
                desc = "Dismiss Copilot Suggestion",
            })
        end,
    },
    {
        "folke/sidekick.nvim",
        opts = {
            signs = {
                enabled = false,
            },
            nes = {
                diff = {
                    inline = "chars",
                },
            },
            cli = {
                win = {
                    layout = "float",
                    float = {
                        width = 1,
                        height = 0.99,
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
