return {
    {
        "github/copilot.vim",
        cmd = "Copilot",
        dependencies = {
            "folke/sidekick.nvim",
        },
        init = function()
            vim.g.copilot_filetypes = {
                ["*"] = true,
                env = false,
            }
            vim.g.copilot_version = false
            vim.g.copilot_node_command = "/Users/aqothy/.local/bin/node"
        end,
    },
    {
        "folke/sidekick.nvim",
        opts = {
            nes = {
                trigger = {
                    events = { "ModeChanged i:n", "TextChanged", "User SidekickNesDone", "LspAttach" },
                },
                diff = {
                    inline = "chars",
                },
                signs = false,
            },
            cli = {
                win = {
                    split = {
                        width = 0.5,
                    },
                    keys = {
                        select = {
                            "<a-.>",
                            function(term)
                                term:hide()
                                require("sidekick.cli").select()
                            end,
                            mode = { "n", "t" },
                            desc = "Select Agent",
                        },
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
                "<leader>aa",
                function() require("sidekick.cli").toggle() end,
                desc = "Sidekick Toggle CLI",
            },
            {
                "<c-.>",
                function() require("sidekick.cli").focus() end,
                desc = "Sidekick Focus",
                mode = { "n", "t", "i", "x" },
            },
            {
                "<leader>as",
                function() require("sidekick.cli").select() end,
                desc = "Select CLI",
            },
            {
                "<leader>ac",
                function() require("sidekick.cli").close() end,
                desc = "Detach a CLI Session",
            },
            {
                "<leader>av",
                function() require("sidekick.cli").send({ msg = "{this}\n{selection}" }) end,
                mode = { "x" },
                desc = "Send Visual Selection",
            },
            {
                "<leader>ad",
                function() require("sidekick.cli").send({ msg = "{diagnostics_all}" }) end,
                mode = { "n", "x" },
                desc = "Send Diagnostic",
            },
        },
    },
}
