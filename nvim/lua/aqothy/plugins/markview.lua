return {
    "OXY2DEV/markview.nvim",
    ft = "markdown", -- If you decide to lazy-load anyway
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons"
    },
    -- TODO: add key bindings and configuration
    config = function()
        require("markview").setup({
            initial_state = true,
            hybrid_modes = { "n" }
        })
        vim.keymap.set(
            "n",
            "<leader>mm",
            "<cmd>Markview splitToggle<CR>",
            { desc = "Open split view for Markdown preview" }
        )
    end,
}
