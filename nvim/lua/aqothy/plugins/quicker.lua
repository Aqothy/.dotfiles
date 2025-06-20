return {
    "stevearc/quicker.nvim",
    event = "FileType qf",
    keys = {
        {
            "<leader>qq",
            function()
                require("quicker").toggle()
            end,
            desc = "Toggle Quickfix",
        },
        {
            "<leader>ql",
            function()
                require("quicker").toggle({ loclist = true })
            end,
            desc = "Toggle Loclist",
        },
    },
    opts = {
        keys = {
            {
                ">",
                function()
                    require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
                    vim.api.nvim_win_set_height(0, math.min(20, vim.api.nvim_buf_line_count(0)))
                end,
                desc = "Expand quickfix context",
            },
            {
                "<",
                function()
                    require("quicker").collapse()
                    vim.api.nvim_win_set_height(0, math.max(4, math.min(10, vim.api.nvim_buf_line_count(0))))
                end,
                desc = "Collapse quickfix context",
            },
        },
    },
}
