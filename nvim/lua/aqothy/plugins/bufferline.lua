return {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = function()
        local keys = {
            { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
            { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
            { "<leader>k", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
            { "<leader>bp", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
            { "<leader>bl", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
            { "<leader>bh", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
        }

        for i = 1, 5 do
            table.insert(keys, {
                "<leader>" .. i,
                "<Cmd>BufferLineGoToBuffer " .. i .. "<CR>",
                desc = "Bufferline " .. i,
            })
        end
        return keys
    end,
    opts = {
        options = {
            show_close_icon = false,
            show_buffer_close_icons = false,
            always_show_bufferline = false,
        },
    },
}
