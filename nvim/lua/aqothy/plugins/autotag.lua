return {
    "windwp/nvim-ts-autotag",
    -- only load for these filetypes
    ft = {
        "typescript",
        "typescriptreact",
        "javascript",
        "javascriptreact",
        "html",
    },
    config = function()
        require("nvim-ts-autotag").setup({
            opts = {
                enable_close = true,
            },
        })
    end,
}
