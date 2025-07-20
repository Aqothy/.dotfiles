return {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
        { "<leader>;", "<cmd>BufferLinePick<cr>", desc = "Pick Buffer" },
    },
    opts = {
        options = {
            show_close_icon = false,
            show_buffer_close_icons = false,
        },
    },
}
