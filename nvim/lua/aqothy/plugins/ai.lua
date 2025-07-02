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
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            { "nvim-lua/plenary.nvim" },
        },
        cmd = { "CodeCompanion", "CodeCompanionChat" },
        opts = {
            adapters = {
                gemini = function()
                    return require("codecompanion.adapters").extend("gemini", {
                        env = {
                            api_key = "cmd:cat ~/gemini_api.txt",
                        },
                    })
                end,
            },
            strategies = {
                chat = {
                    adapter = {
                        name = "copilot",
                        model = "gemini-2.5-pro-preview-06-05",
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
                            number = false,
                            relativenumber = false,
                        },
                    },
                },
            },
        },
        keys = {
            { "<leader>ac", ":CodeCompanionActions<CR>", desc = "Open the action palette", mode = { "n", "x" }, silent = true },
            { "<Leader>ai", ":CodeCompanionChat Toggle<CR>", desc = "Toggle a chat buffer", silent = true },
            { "<leader>aa", ":CodeCompanionChat Add<CR>", desc = "Add code to a chat buffer", mode = "x", silent = true },
        },
    },
}
