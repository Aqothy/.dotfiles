local function agent(action)
    local terms = {}
    for _, s in ipairs(require("sidekick.cli.state").get({ attached = true })) do
        if s.terminal then
            table.insert(terms, s.terminal)
        end
    end

    if action == "focus" then
        for _, t in ipairs(terms) do
            if t:is_open() then
                t:focus()
                return
            end
        end

        require("sidekick.cli").focus()
        return
    end

    if #terms < 2 then
        return
    end

    -- Sort for consistent cycling
    table.sort(terms, function(a, b)
        return a.tool.name < b.tool.name
    end)

    local idx
    for i, t in ipairs(terms) do
        if t:is_open() then
            idx = i
            break
        end
    end

    if idx then
        terms[idx]:hide()

        local step = action == "next" and 1 or -1
        local target = terms[((idx - 1 + step) % #terms) + 1]

        target:focus()
        vim.schedule(function()
            vim.cmd.startinsert()
        end)
    end
end

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
                        cycle_prev = {
                            "<A-[>",
                            function()
                                agent("prev")
                            end,
                            mode = { "n", "t" },
                            desc = "Cycle Prev Agent",
                        },
                        cycle_next = {
                            "<A-]>",
                            function()
                                agent("next")
                            end,
                            mode = { "n", "t" },
                            desc = "Cycle Next Agent",
                        },
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
                function() agent("focus") end,
                desc = "Sidekick Focus",
                mode = { "n", "t" },
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
