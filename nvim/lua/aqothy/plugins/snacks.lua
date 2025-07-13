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
                chunk = { enabled = false },
                scope = { enabled = false },
                filter = function(buf)
                    return vim.bo[buf].filetype ~= "snacks_picker_preview"
                        and vim.bo[buf].filetype ~= "bigfile"
                        and vim.g.snacks_indent ~= false
                        and vim.b[buf].snacks_indent ~= false
                        and vim.bo[buf].buftype == ""
                end,
                animate = {
                    enabled = false,
                },
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
                sources = {
                    files = {
                        hidden = true,
                    },
                },
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
                layouts = {
                    default = {
                        layout = {
                            backdrop = false,
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
        { "<leader>nn", function() Snacks.notifier.hide() end, desc = "Hide Notifications" },
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
        { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log File" },
        { "<leader>fl", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },
        { "<leader>pr", function() Snacks.picker.resume() end, desc = "Resume Last Picker" },
        { "<leader>pa", function() Snacks.picker() end, desc = "All Pickers" },
        { "<leader>pn", function() Snacks.picker.notifications() end, desc = "Pick Notifications" },
        { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
        { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Find keymaps" },
        { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files Root" },
        { "<leader>fs", function() Snacks.picker.grep() end, desc = "Grep" },
        { "<leader>ph", function() Snacks.picker.highlights() end, desc = "Highlights" },
        { "<leader>fh", function() Snacks.picker.help() end, desc = "Help Pages" },
        { "<leader>/", function() Snacks.picker.lines() end, desc = "Grep Lines" },
        { "<leader>u", function() Snacks.picker.undo() end, desc = "undo tree" },
        { "z=", function() Snacks.picker.spelling() end, desc = "Spelling" },
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
