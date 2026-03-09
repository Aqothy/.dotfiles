return {
    "kylechui/nvim-surround",
    keys = {
        { "ys", "<Plug>(nvim-surround-normal)", desc = "Surround Normal" },
        { "yss", "<Plug>(nvim-surround-normal-cur)", desc = "Surround Current Line" },
        { "S", "<Plug>(nvim-surround-visual)", mode = "x", desc = "Surround Visual" },
        { "ds", "<Plug>(nvim-surround-delete)", desc = "Delete Surrounding" },
        { "cs", "<Plug>(nvim-surround-change)", desc = "Change Surrounding" },
    },
    init = function()
        vim.g.nvim_surround_no_mappings = true
    end,
    opts = {},
}
