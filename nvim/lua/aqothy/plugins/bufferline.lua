return {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
        { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
        { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
        { "<leader>bl", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
        { "<leader>bh", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
        { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
        { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    },
    opts = {
        options = {
            close_command = function(n)
                Snacks.bufdelete(n)
            end,
            right_mouse_command = function(n)
                Snacks.bufdelete(n)
            end,
            separator_style = "slope",
            diagnostics = "nvim_lsp",
            always_show_bufferline = false,
            show_close_icon = false,
            show_buffer_close_icons = false,
            indicator = { style = "underline" },
            diagnostics_indicator = function(_, _, diag)
                local icons = require("aqothy.config.user").signs
                local indicator = (diag.error and icons.error .. " " or "") .. (diag.warning and icons.warn or "")
                return vim.trim(indicator)
            end,
        },
    },
}
