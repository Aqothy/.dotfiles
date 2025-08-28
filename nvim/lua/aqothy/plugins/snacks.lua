return {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    opts = function()
        local icons = require("aqothy.config.icons")
        return {
            bigfile = { enabled = true },

            input = { enabled = true },

            notifier = {
                enabled = true,
                icons = icons.signs,
                level = vim.log.levels.INFO,
            },

            quickfile = { enabled = true },

            words = {
                enabled = true,
                modes = { "n" },
            },

            picker = {
                enabled = true,
                icons = {
                    kinds = icons.kinds,
                },
                ui_select = true,
                win = {
                    input = {
                        keys = {
                            ["<a-.>"] = { "toggle_hidden", mode = { "i", "n" } },
                            ["<a-h>"] = false,
                        },
                    },
                    list = {
                        keys = {
                            ["<a-.>"] = "toggle_hidden",
                            ["<a-h>"] = false,
                        },
                    },
                },
                sources = {
                    aqfiles = {
                        layout = {
                            preview = false,
                        },
                        multi = { "recent", "files" },
                        format = "file",
                        filter = { cwd = true },
                        hidden = true,
                        transform = "unique_file",
                        sort = { fields = { "score:desc", "idx" } },
                    },
                    buffers = {
                        layout = {
                            preview = false,
                        },
                    },
                    grep = {
                        hidden = true,
                    },
                    grep_word = {
                        hidden = true,
                    },
                },
            },

            image = {
                enabled = false,
                convert = {
                    notify = false,
                },
            },

            styles = {
                notification = {
                    wo = { wrap = true },
                },
                terminal = {
                    wo = {
                        winbar = "",
                    },
                },
                lazygit = {
                    width = 0,
                    height = 0.99,
                },
            },
        }
    end,
    -- stylua: ignore
    keys = {
        { "<leader>go", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "x" } },
        ---@diagnostic disable-next-line: missing-fields
        { "<leader>gy", function() Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false }) end, desc = "Git Browse (copy)", mode = { "n", "x" },  },
        { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
        { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
        { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },
        { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
        {"<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete Other Buffers" },
        { "<c-j>", function() Snacks.terminal(nil, { win = { position = "float", border = "rounded", width = 0.7, height = 0.7 } }) end, desc = "Toggle Terminal", mode = { "n", "t" } },
        {
            "<leader>no",
            function()
                ---@diagnostic disable-next-line: missing-fields
                Snacks.scratch({
                    icon = " ",
                    name = "Todo",
                    ft = "markdown",
                    file = vim.fn.stdpath("state") .. "/TODO.md"
                })
            end,
            desc = "Todo List",
        },
        { "<leader>.", function() Snacks.picker.resume() end, desc = "Resume Last Picker" },
        { "<leader><leader>", function() Snacks.picker({ layout = { preview = false } }) end, desc = "Pick" },
        { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
        { "<leader>f", function() Snacks.picker.pick("aqfiles") end, desc = "Find Files Smart" },
        { "<leader>s", function() Snacks.picker.grep() end, desc = "Grep" },
        { "<leader>?", function() Snacks.picker.help() end, desc = "Help Pages" },
        { "<leader>u", function() Snacks.picker.undo({ layout = { preset = "sidebar" } }) end, desc = "undo tree" },
        { "<leader>*", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
        { "<leader>pp", function() Snacks.toggle.profiler():toggle() end, desc = "Profiler Picker" },
        { "<leader>/", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
    },
}
