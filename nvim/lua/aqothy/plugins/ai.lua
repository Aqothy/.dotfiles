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
                codecompanion = false,
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
                        model = "claude-3.7-sonnet",
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
                    intro_message = "",
                    window = {
                        opts = {
                            breakindent = false,
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
            { "<leader>aa", "<cmd>CodeCompanionChat Add<CR>", desc = "Add code to a chat buffer", mode = "x" },
        },
    },
}
