return {
    {
        "github/copilot.vim",
        event = "BufReadPost",
        init = function()
            vim.g.copilot_lsp_settings = {
                telemetry = {
                    telemetryLevel = "off",
                },
            }
            vim.g.copilot_settings = { selectedCompletionModel = "gpt-4o-copilot" }
            vim.g.copilot_no_tab_map = true
        end,
        config = function()
            vim.keymap.set("i", "<M-a>", 'copilot#Accept("")', {
                expr = true,
                replace_keycodes = false,
                desc = "Accept suggestions",
            })
            vim.g.copilot_filetypes = {
                ["*"] = true,
                dotenv = false,
            }
        end,
    },
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            { "nvim-lua/plenary.nvim" },
        },
        cmd = { "CodeCompanion", "CodeCompanionChat" },
        opts = {
            strategies = {
                chat = {
                    adapter = {
                        name = "copilot",
                        model = "claude-sonnet-4",
                    },
                    roles = {
                        user = "Aqothy",
                    },
                },
                inline = {
                    adapter = {
                        name = "copilot",
                        model = "gpt-4.1",
                    },
                },
            },
            display = {
                chat = {
                    window = {
                        opts = {
                            number = false,
                            relativenumber = false,
                        },
                    },
                },
            },
        },
        keys = {
            { "<leader>ac", "<cmd>CodeCompanionActions<CR>", desc = "Open the action palette", mode = { "n", "x" } },
            { "<Leader>ai", "<cmd>CodeCompanionChat Toggle<CR>", desc = "Toggle a chat buffer", mode = { "n", "x" } },
            { "<leader>aa", "<cmd>CodeCompanionChat Add<CR>", desc = "Add code to a chat buffer", mode = { "x" } },
        },
    },
}
