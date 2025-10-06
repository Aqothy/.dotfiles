return {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
        fast_wrap = {
            chars = { "{", "[", "(", '"', "'", "<" },
            end_key = "e",
        },
    },
}
