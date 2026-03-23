return {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
        code = { border = "thin" },
        heading = {
            icons = {},
        },
        sign = { enabled = false },
        overrides = { -- LSP hovers: hide code block lines
            buftype = {
                nofile = {
                    code = { border = "hide", style = "normal" },
                },
            },
        },
    },
    ft = "markdown",
    keys = {
        { "<localleader>mp", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Markdown Preview", ft = "markdown" },
    },
}
