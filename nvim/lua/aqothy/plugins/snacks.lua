return {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    opts = function()
        local icons = require("aqothy.config.icons")
        return {
            dashboard = { enabled = false },

            bigfile = { enabled = true },

            scroll = { enabled = false },

            indent = {
                enabled = false,
                indent = { enabled = true, char = "▏" },
                scope = { enabled = true, char = "▎" },
                animate = { enabled = false },
            },

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

            zen = {
                toggles = {
                    dim = false,
                },
            },

            dim = {
                scope = {
                    min_size = 1,
                },
                animate = {
                    enabled = false,
                },
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
                formatters = {
                    file = {
                        filename_first = true,
                    },
                },
                layout = {
                    preset = "vertical",
                },
                layouts = {
                    vertical = {
                        layout = {
                            backdrop = false,
                            width = 0.5,
                            min_width = 80,
                            height = 0.8,
                            min_height = 30,
                            box = "vertical",
                            border = "rounded",
                            title = "{title} {live} {flags}",
                            title_pos = "center",
                            { win = "input", height = 1, border = "bottom" },
                            { win = "list", height = 12, border = "none" },
                            { win = "preview", title = "{preview}", border = "top" },
                        },
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
                zen = {
                    width = function()
                        return math.min(120, math.floor(vim.o.columns * 0.75))
                    end,
                    backdrop = {
                        transparent = false,
                        blend = 95,
                    },
                },
                terminal = {
                    wo = {
                        winbar = "",
                    },
                    keys = {
                        term_normal = false,
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
        { "<leader>gh", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "x" } },
        ---@diagnostic disable-next-line: missing-fields
        { "<leader>gy", function() Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false }) end, desc = "Git Browse (copy)", mode = { "n", "x" },  },
        { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
        {"<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete Other Buffers" },
        { "<c-j>", function() Snacks.terminal() end, desc = "Toggle Terminal", mode = { "n", "t" } },
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
        { "<leader>gs", function() Snacks.lazygit() end, desc = "Lazygit (cwd)" },
        { "<leader>pr", function() Snacks.picker.resume() end, desc = "Resume Last Picker" },
        { "<leader>pa", function() Snacks.picker() end, desc = "All Pickers" },
        { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
        { "<leader>ff", function() Snacks.picker.pick("aqfiles", {
            multi = { "buffers", "recent", "files" },
            format = "file",
            filter = { cwd = true },
            hidden = true,
            transform = "unique_file",
            sort = { fields = { "score:desc", "idx" } },
            layout = { preview = false },
        }) end, desc = "Find Files Smart" },
        { "<leader>fs", function() Snacks.picker.grep() end, desc = "Grep" },
        { "<leader>fh", function() Snacks.picker.help() end, desc = "Help Pages" },
        { "<leader>u", function() Snacks.picker.undo() end, desc = "undo tree" },
        { "<leader>fw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
    },
    init = function()
        vim.api.nvim_create_autocmd("User", {
            pattern = "VeryLazy",
            group = vim.api.nvim_create_augroup("aqothy/snacks_lazyload", { clear = true }),
            callback = function()
                _G.dd = function(...)
                    Snacks.debug.inspect(...)
                end
                _G.bt = function()
                    Snacks.debug.backtrace()
                end
                vim.print = _G.dd

                -- Toggle
                Snacks.toggle.dim():map("<leader>sd")
                Snacks.toggle.diagnostics():map("<leader>td")
                Snacks.toggle.zen():map("<leader>zz")
                Snacks.toggle.profiler():map("<leader>pp")
                Snacks.toggle.indent():map("<leader>id")
            end,
        })
    end,
}
