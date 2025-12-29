return {
    {
        "github/copilot.vim",
        event = "LazyFile",
        init = function()
            vim.g.copilot_no_tab_map = true
            vim.g.copilot_filetypes = {
                ["*"] = true,
                dotenv = false,
            }
            vim.g.copilot_lsp_settings = {
                telemetry = {
                    telemetryLevel = "off",
                },
            }
            vim.g.copilot_version = false
        end,
        config = function()
            vim.keymap.set("i", "<s-tab>", 'copilot#Accept("\\<s-tab>")', {
                expr = true,
                replace_keycodes = false,
                desc = "Accept Copilot Suggestion",
            })
            vim.keymap.set("n", "<leader>tc", function()
                if vim.fn["copilot#Enabled"]() == 1 then
                    vim.cmd("Copilot disable")
                else
                    vim.cmd("Copilot enable")
                end
                vim.cmd("Copilot status")
                vim.cmd("Sidekick nes toggle")
            end, { desc = "Toggle Copilot" })
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
                    split = {
                        width = 0.4,
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
                "<leader>ad",
                function() require("sidekick.cli").close() end,
                desc = "Detach a CLI Session",
            },
            {
                "<leader>af",
                function() require("sidekick.cli").send({ msg = "{file}" }) end,
                desc = "Send File",
            },
            {
                "<leader>av",
                function() require("sidekick.cli").send({ msg = "{this}" }) end,
                mode = { "x", "n" },
                desc = "Send This",
            },
        },
    },
}
