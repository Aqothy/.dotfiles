return {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
        code = {
            sign = false,
            width = "block",
            right_pad = 1,
        },
        heading = {
            sign = false,
            icons = {},
        },
        checkbox = {
            enabled = false,
        },
    },
    ft = "markdown",
    keys = {
        { "<localleader>mp", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Markdown Preview", ft = "markdown" },
    },
}
