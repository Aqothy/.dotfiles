return {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    opts = function()
        local user = require("aqothy.config.user")
        local in_git = Snacks.git.get_root() ~= nil

        return {
            dashboard = {
                enabled = false,
                preset = {
                    header = [[
        ⣤⡀⠀⣶⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠙⣿⣆⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠸⣷⣮⣿⣿⣄⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢀⡠⠒⠉⠀⠀⠀⠀⠀⠀⠈⠁⠲⢖⠒⡀⠀⠀
⠀⠀⠀⡠⠴⣏⠀⢀⡀⠀⢀⡀⠀⠀⠀⡀⠀⠀⡀⠱⡈⢄⠀
⠀⠀⢠⠁⠀⢸⠐⠁⠀⠄⠀⢸⠀⠀⢎⠀⠂⠀⠈⡄⢡⠀⢣
⠀⢀⠂⠀⠀⢸⠈⠢⠤⠤⠐⢁⠄⠒⠢⢁⣂⡐⠊⠀⡄⠀⠸
⠀⡘⠀⠀⠀⢸⠀⢠⠐⠒⠈⠀⠀⠀⠀⠀⠀⠈⢆⠜⠀⠀⢸
⠀⡇⠀⠀⠀⠀⡗⢺⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠑⡄⢀⠎
⠀⢃⠀⠀⠀⢀⠃⢠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠷⡃⠀
⠀⠈⠢⣤⠀⠈⠀⠀⠑⠠⠤⣀⣀⣀⣀⣀⡀⠤⠒⠁⠀⢡⠀
⡀⣀⠀⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢘⠀
⠑⢄⠉⢳⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡸⠀
⠀⠀⠑⠢⢱⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⠁⠀
⠀⠀⠀⠀⢀⠠⠓⠢⠤⣀⣀⡀⠀⠀⣀⣀⡀⠤⠒⠑⢄⠀⠀
⠀⠀⠀⠰⠥⠤⢄⢀⡠⠄⡈⡀⠀⠀⣇⣀⠠⢄⠀⠒⠤⠣⠀
⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀]],
                    -- stylua: ignore
                    keys = {
                        { icon = " ", key = "b", desc = "Browse Repo", enabled = in_git, action = function() Snacks.gitbrowse() end },
                        { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
                        { icon = " ", key = "g", desc = "Git status", enabled = in_git, action = function() Snacks.lazygit() end },
                        { icon = " ", key = "t", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
                        {
                            icon = " ",
                            key = "e",
                            desc = "New File",
                            action = function()
                                local current_dir = vim.fn.expand("%:p:h") .. "/"
                                vim.ui.input({
                                    prompt = "File: ",
                                    default = current_dir,
                                }, function(file)
                                    if file and file ~= "" then
                                        vim.cmd("e " .. file .. " | startinsert | e")
                                    end
                                end)
                            end,
                        },
                        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
                    },
                },
                sections = {
                    { section = "header", padding = { 0, 1 } },
                    { section = "keys", padding = 1 },
                    {
                        section = "recent_files",
                        cwd = true,
                        padding = 1,
                    },
                    {
                        section = "projects",
                    },
                },
            },

            bigfile = { enabled = true },

            scroll = { enabled = false },

            indent = {
                enabled = false,
                indent = { enabled = true, char = "▏" },
                chunk = { enabled = false },
                scope = { enabled = true, char = "▎" },
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
                icons = user.signs,
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
                    smart = {
                        filter = { cwd = true },
                    },
                    recent = {
                        filter = { cwd = true },
                    },
                    grep = {
                        hidden = true,
                    },
                    grep_word = {
                        hidden = true,
                    },
                    explorer = {
                        hidden = true,
                    },
                },
                icons = {
                    kinds = user.kinds,
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
                            ["<a-.>"] = { "toggle_hidden", mode = { "i", "n" } },
                            ["<a-h>"] = false,
                        },
                    },
                },
                layouts = {
                    default = {
                        layout = {
                            backdrop = false,
                        },
                    },
                    sidebar = {
                        layout = {
                            width = 30,
                        },
                    },
                },
            },

            explorer = {
                replace_netrw = true,
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
                        blend = 99,
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
                    height = 0,
                },
            },
        }
    end,
    -- stylua: ignore
    keys = {
        { "<leader>bl", function() Snacks.git.blame_line() end, desc = "Git blame Line", mode = { "n", "x" } },
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
        ---@diagnostic disable-next-line: missing-fields
        { "<leader>ee", function() Snacks.explorer() end, desc = "File Explorer" },
        {
            "<leader>to",
            function()
                Snacks.picker.grep({
                    search = [[TODO:|todo!\(.*\)]],
                    live = false,
                    supports_live = false,
                    on_show = function()
                        vim.cmd("stopinsert")
                    end,
                })
            end,
            desc = "Grep TODOs"
        },
        { "<leader>pr", function() Snacks.picker.resume() end, desc = "Resume Last Picker" },
        { "<leader>pa", function() Snacks.picker() end, desc = "All Pickers" },
        { "<leader>pi", function() Snacks.picker.icons() end, desc = "Pick icons" },
        { "<leader>pn", function() Snacks.picker.notifications() end, desc = "Pick Notifications" },
        {
            "<leader>,",
            function()
                Snacks.picker.buffers({
                    on_show = function()
                        vim.cmd("stopinsert")
                    end,
                })
            end,
            desc = "Buffers" },
        { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
        { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Find keymaps" },
        { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
        { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart File Picker" },
        { "<leader>of", function() Snacks.picker.recent() end, desc = "Recent" },
        { "<leader>fs", function() Snacks.picker.grep() end, desc = "Grep" },
        { "<leader>ph", function() Snacks.picker.highlights() end, desc = "Highlights" },
        { "<leader>fq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
        { "<leader>fh", function() Snacks.picker.help() end, desc = "Help Pages" },
        { "<leader>/", function() Snacks.picker.lines() end, desc = "Grep Lines" },
        { "<leader>u", function() Snacks.picker.undo() end, desc = "undo tree" },
        { "<leader>fp", function() Snacks.picker.projects({ dev = { "~/Code/Personal" } }) end, desc = "Projects picker" },
        { "<leader>ps", function() Snacks.picker.spelling() end, desc = "Spelling" },
        { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command history" },
        { "<leader>fw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
    },
    init = function()
        vim.api.nvim_create_autocmd("User", {
            pattern = "VeryLazy",
            group = vim.api.nvim_create_augroup("snacks_lazyload", { clear = true }),
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
                Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>sp")
                Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>rn")
                Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>tw")
            end,
        })
    end,
}
