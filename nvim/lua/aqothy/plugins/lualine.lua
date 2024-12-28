return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons"
    },
    -- event = "VeryLazy",
    -- init = function()
    --     vim.g.lualine_laststatus = vim.opt.laststatus
    --     if vim.fn.argc(-1) > 0 then
    --         -- set an empty statusline till lualine loads
    --         vim.opt.statusline = " "
    --     else
    --         -- hide the statusline on the starter page
    --         vim.opt.laststatus = 0
    --     end
    -- end,
    config = function()
        local lualine = require("lualine")

        lualine.setup({
            sections = {
                lualine_a = { 'mode' },
                lualine_b = { 'branch', 'diff', 'diagnostics' },
                lualine_c = {
                    { "filename", path = 1 },
                },
                lualine_x = {
                    { "encoding" },
                    { "fileformat" },
                    { "filetype" },
                    { "filesize" },
                    {
                        -- macro recording
                        function()
                            local recording = vim.fn.reg_recording()
                            if recording ~= "" then
                                return "Recording @" .. recording
                            end
                            return ""
                        end,
                        color = { fg = "#ff9e64" },
                    }
                },
                lualine_y = {
                    { "progress", separator = " ",                  padding = { left = 1, right = 0 } },
                    { "location", padding = { left = 0, right = 1 } },
                },
                lualine_z = {
                    function()
                        return " " .. os.date("%R")
                    end,
                },
            },
            options = {
                theme = "gruvbox-material",
                globalstatus = vim.opt.laststatus == 3,
                disabled_buftypes = { "quickfix", "prompt", "nofile" },
                disabled_filetypes = {
                    statusline = {
                        "",
                        "qf",
                        "help",
                        -- "oil",
                        "lazy",
                        "NeogitStatus",
                        "noice",
                        "snacks_dashboard",
                        "snacks_terminal",
                        "NvimTree",
                        "trouble",
                        "fugitive",
                        "leetcode.nvim",
                        "mason",
                        "terminal",
                        "fzf",
                    },
                },
            },
        })
    end,
}
