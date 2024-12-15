return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        local lualine = require("lualine")

        lualine.setup({
            sections = {
                lualine_x = {
                    { "encoding" },
                    { "fileformat" },
                    { "filetype" },
                    { "filesize" },
                    { "filename",  path = 2 },
                },
            },
            options = {
                disabled_filetypes = {
                    statusline = {
                        "help",
                        "lazy",
                        "alpha",
                        "NvimTree",
                        "Trouble",
                        "fugitive",
                        "leetcode.nvim",
                    },
                },
            },
        })
    end,
}
