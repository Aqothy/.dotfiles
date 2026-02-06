return {
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1001,
        config = function()
            local gruvbox = require("gruvbox")

            local colors = gruvbox.palette

            local is_dark = vim.o.background == "dark"
            local overrides

            if is_dark then
                overrides = {
                    NormalFloat = { bg = colors.dark0_soft },
                    SignColumn = { bg = colors.dark0_soft },
                    Pmenu = { bg = colors.dark0_soft },
                    LspReferenceText = { link = "Visual" },
                    LspReferenceRead = { link = "Visual" },
                    LspReferenceWrite = { link = "Visual" },
                    DiffText = { link = "DiffAdd" },
                    TreesitterContext = { bg = colors.dark1 },
                }
            else
                overrides = {
                    NormalFloat = { bg = colors.light0_soft },
                    SignColumn = { bg = colors.light0_soft },
                    Pmenu = { bg = colors.light0_soft },
                    LspReferenceText = { bg = "#CAC2A6" },
                    LspReferenceRead = { bg = "#CAC2A6" },
                    LspReferenceWrite = { bg = "#CAC2A6" },
                    DiffText = { link = "DiffAdd" },
                    TreesitterContext = { bg = colors.light1 },
                }
            end

            gruvbox.setup({
                contrast = "soft",
                overrides = overrides,
            })

            vim.cmd("colorscheme gruvbox")

            local base_bg = is_dark and colors.dark0_soft or colors.light0_soft
            local blend = require("custom.utils").blend

            local custom_hls = {
                DiffviewChangeDelete = { bg = "#5a332f" },
                DiagnosticVirtualTextError = { bg = blend(colors.bright_red, 0.12, base_bg), fg = colors.bright_red },
                DiagnosticVirtualTextWarn = {
                    bg = blend(colors.bright_yellow, 0.12, base_bg),
                    fg = colors.bright_yellow,
                },
                DiagnosticVirtualTextInfo = { bg = blend(colors.bright_blue, 0.12, base_bg), fg = colors.bright_blue },
                DiagnosticVirtualTextHint = { bg = blend(colors.bright_aqua, 0.12, base_bg), fg = colors.bright_aqua },
            }

            for name, opts in pairs(custom_hls) do
                vim.api.nvim_set_hl(0, name, opts)
            end
        end,
    },
}
