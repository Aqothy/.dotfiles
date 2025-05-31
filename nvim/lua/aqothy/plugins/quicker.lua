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
            "<leader>xx",
            function()
                local success, err =
                    pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.diagnostic.setqflist)
                if not success and err then
                    vim.notify(err, vim.log.levels.ERROR)
                end
            end,
            desc = "Toggle Diagnostic Quickfix",
        },
    },
    opts = {
        keys = {
            {
                ">",
                function()
                    require("quicker").expand({ before = 3, after = 3, add_to_existing = true })
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
