return {
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1001,
        config = function()
            local gruvbox = require("gruvbox")
            local colors = gruvbox.palette

            local custom_hls = {
                DiffviewChangeDelete = { bg = "#5a332f" },
            }

            local function get_overrides()
                if vim.o.background == "dark" then
                    return {
                        SignColumn = { bg = colors.dark0_soft },
                        FoldColumn = { bg = colors.dark0_soft },
                        Pmenu = { bg = colors.dark0_soft },
                        LspReferenceText = { link = "Visual" },
                        LspReferenceRead = { link = "Visual" },
                        LspReferenceWrite = { link = "Visual" },
                        DiffText = { link = "DiffAdd" },
                    }
                end

                return {
                    SignColumn = { bg = colors.light0_soft },
                    FoldColumn = { bg = colors.light0_soft },
                    Pmenu = { bg = colors.light0_soft },
                    LspReferenceText = { bg = "#CAC2A6" },
                    LspReferenceRead = { bg = "#CAC2A6" },
                    LspReferenceWrite = { bg = "#CAC2A6" },
                    DiffText = { link = "DiffAdd" },
                }
            end

            local function apply_gruvbox()
                gruvbox.setup({
                    contrast = "soft",
                    overrides = get_overrides(),
                })

                vim.cmd.colorscheme("gruvbox")

                for name, opts in pairs(custom_hls) do
                    vim.api.nvim_set_hl(0, name, opts)
                end
            end

            apply_gruvbox()

            local group = vim.api.nvim_create_augroup("BackgroundSync", { clear = true })
            vim.api.nvim_create_autocmd("OptionSet", {
                group = group,
                pattern = "background",
                callback = apply_gruvbox,
            })
        end,
    },
}
