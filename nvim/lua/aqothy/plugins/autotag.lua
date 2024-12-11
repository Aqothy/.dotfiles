return {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    config = function()
        require("nvim-ts-autotag").setup(
            {
                opts = {
                    enable_close = false, -- Auto close tags, dont need it if you have emmet lsp
                },
            }
        )
    end,
}
