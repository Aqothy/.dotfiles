return {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
        code = {
            sign = false,
        },
        heading = {
            sign = false,
            icons = {},
        },
    },
    ft = "markdown",
    keys = {
        { "<localleader>mp", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Markdown Preview", ft = "markdown" },
    },
}
