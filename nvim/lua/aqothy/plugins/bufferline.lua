return {
    "akinsho/bufferline.nvim",
    event = "BufReadPre",
    keys = {
        { "<leader>;", "<cmd>BufferLinePick<cr>", desc = "Pick Buffer" },
        { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
        { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
        { "<leader>bl", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
        { "<leader>bh", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
    },
    opts = {
        options = {
            show_close_icon = false,
            show_buffer_close_icons = false,
            always_show_bufferline = false,
        },
    },
}
