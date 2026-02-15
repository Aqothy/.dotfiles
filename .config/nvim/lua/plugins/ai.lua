return {
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        opts = {
            panel = {
                enabled = false,
            },
            suggestion = {
                auto_trigger = true,
                keymap = {
                    accept = "<c-l>",
                },
            },
            filetypes = {
                markdown = true,
                dotenv = false,
            },
        },
    },
    {
        "folke/sidekick.nvim",
        event = "LazyFile",
        dependencies = {
            "zbirenbaum/copilot.lua",
        },
        opts = {
            signs = {
                enabled = false,
            },
            nes = {
                debounce = 15,
                trigger = {
                    events = { "ModeChanged i:n", "TextChanged", "User SidekickNesDone", "LspAttach" },
                },
                diff = {
                    inline = "chars",
                },
            },
            cli = {
                win = {
                    split = {
                        width = 0.35,
                    },
                },
            },
        },
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
                function() require("sidekick.cli").send({ msg = "{selection}" }) end,
                mode = { "x" },
                desc = "Send Visual Selection",
            },
            {
                "<leader>ap",
                function() require("sidekick.cli").prompt() end,
                mode = { "n", "x" },
                desc = "Sidekick Select Prompt",
            },
        },
    },
}
