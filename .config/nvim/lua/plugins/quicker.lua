return {
    "stevearc/quicker.nvim",
    event = "FileType qf",
    opts = {
        highlight = {
            lsp = false,
        },
        keys = {
            {
                ">",
                function()
                    require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
                end,
                desc = "Expand quickfix context",
            },
            {
                "<",
                function()
                    require("quicker").collapse()
                end,
                desc = "Collapse quickfix context",
            },
        },
    },
    keys = {
        {
            "<c-q>",
            function()
                require("quicker").toggle()
            end,
            desc = "Toggle quickfix",
        },
    },
}
