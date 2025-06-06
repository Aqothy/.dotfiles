return {
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        keys = {
            {
                "<leader>tc",
                function()
                    Snacks.toggle({
                        name = "Copilot",
                        get = function()
                            return not require("copilot.client").is_disabled()
                        end,
                        set = function(state)
                            vim.cmd("Copilot " .. (state and "enable" or "disable"))
                        end,
                    }):toggle()
                end,
                desc = "Toggle Copilot",
            },
        },
        opts = {
            panel = {
                enabled = false,
            },
            suggestion = {
                enabled = true,
                auto_trigger = true,
                keymap = {
                    accept = "<M-a>",
                    next = "<M-]>",
                    prev = "<M-[>",
                    dismiss = "<C-]>",
                },
            },
            copilot_model = "gpt-4o-copilot",
            filetypes = {
                dotenv = false,
                ["*"] = true,
            },
            server_opts_overrides = {
                settings = {
                    telemetry = {
                        telemetryLevel = "off",
                    },
                },
            },
        },
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
