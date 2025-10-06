return {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    opts = {
        bigfile = { enabled = true },

        input = { enabled = true },

        notifier = { enabled = true },

        quickfile = { enabled = true },

        words = {
            enabled = true,
            modes = { "n" },
        },

        picker = {
            enabled = true,
            ui_select = true,
            icons = {
                kinds = require("aqothy.config.icons").kinds,
            },
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

        zen = {
            toggles = {
                dim = false,
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
            lazygit = {
                width = 0,
                height = 0.99,
                keys = {
                    quit = {
                        "q",
                        function()
                            vim.cmd("close")
                        end,
                        mode = "t",
                        desc = "Quit Lazygit Persistent",
                    },
                },
            },
            zen = {
                width = function()
                    return math.min(120, math.floor(vim.o.columns * 0.65))
                end,
                backdrop = {
                    transparent = false,
                    blend = 95,
                },
            },
        },
    },
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
        { "<leader>zz", function() Snacks.toggle.zen():toggle() end, desc = "Zen Mode" },
        { "<leader>/", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
        { "<leader>ld", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
        { "<leader>lD", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
    },
}
