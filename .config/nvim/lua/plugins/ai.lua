return {
    {
        "zbirenbaum/copilot.lua",
        event = "LazyFile",
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
                        width = 0.35,
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
            {
                "<leader>ap",
                function() require("sidekick.cli").prompt() end,
                mode = { "n", "x" },
                desc = "Sidekick Select Prompt",
            },
        },
    },
}
