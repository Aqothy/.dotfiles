return {
    -- "nvim already has built in comment support, just need to add this for comments for tsx and jsx"
    "folke/ts-comments.nvim",
    opts = {},
    -- only load for these filetypes
    ft = {
        "typescript",
        "typescriptreact",
        "javascript",
        "javascriptreact",
        "html",
    },
    enabled = vim.fn.has("nvim-0.10.0") == 1,
}
