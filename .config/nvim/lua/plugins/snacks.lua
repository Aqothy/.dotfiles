local git_ref_opts = {
    actions = {
        ["diff_commit"] = function(picker)
            local currentCommit = picker:current().commit
            if currentCommit then
                picker:close()
                local args = { currentCommit .. "^" .. "!" }
                require("diffview").open(args)
            end
        end,
        ["copy_commit"] = function(picker)
            local currentCommit = picker:current().commit
            if currentCommit then
                vim.fn.setreg("+", currentCommit)
                vim.notify("Copied commit: " .. currentCommit, vim.log.levels.INFO)
            end
        end,
    },
    win = {
        input = {
            keys = {
                ["<c-o>"] = { "diff_commit", desc = "Diff this commit", mode = { "n", "i" } },
                ["<c-y>"] = { "copy_commit", desc = "Copy commit", mode = { "n", "i" } },
            },
        },
    },
}

local symbol_opts = {
    keep_parents = true,
    layout = {
        preset = "dropdown",
        preview = "main",
        layout = {
            max_width = 60,
        },
    },
    -- open at symbol containing cursor: https://github.com/folke/snacks.nvim/issues/1057
    on_show = function(picker)
        local row = vim.api.nvim_win_get_cursor(picker.main)[1] - 1

        picker.matcher.task:on(
            "done",
            vim.schedule_wrap(function()
                local items = picker:items()

                for i = #items, 1, -1 do
                    local range = items[i].range
                    if range and row >= range.start.line and row <= range["end"].line then
                        picker.list:move(i, true)
                        return
                    end
                end
            end)
        )
    end,
    filter = {
        default = {
            "Class",
            "Constructor",
            "Enum",
            "Function",
            "Interface",
            "Module",
            "Method",
            "Struct",
            "Variable",
            "Property",
            "Constant",
            "Field",
            "Namespace",
        },
    },
}

return {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    init = function()
        vim.g.snacks_animate = false
    end,
    opts = {
        dashboard = {
            preset = {
                header = [[
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢠⣿⣄⣤⣤⣤⣤⣼⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀
⠀⠀⠀⠀⣠⣾⣿⣻⡵⠖⠛⠛⠛⢿⣿⣶⣴⣿⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⠏⢷⡄⠀⠀⠀
⠀⣤⣤⡾⣯⣿⡿⠋⠀⠀⠀⠀⠀⠀⠈⠙⢿⣿⣷⣤⣴⣾⠆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⠏⠀⠈⢻⣦⡀⠀
⠀⢹⣿⣴⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⢿⣿⣿⣄⡀⢀⣤⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣶⠀⠈⠻⣦⠀⠀⣼⠋⠀⠀
⠀⣼⢉⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⢿⣿⣿⣿⣥⠤⠴⣶⣶⣶⣶⣶⣶⣶⣶⣾⣿⠿⣿⣿⣿⣿⡇⣸⠋⠻⣿⣷
⢰⡏⢸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⢿⣿⣶⣶⣿⣟⣿⣟⣛⣭⣉⣩⣿⣿⡀⣼⣿⣿⣿⣿⣿⣄⠀⣸⣿
⢿⡇⢸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⣿⣿⣿⠿⠿⠛⠛⠛⠛⠛⠻⣿⣿⣭⣉⢉⣿⣿⠟⣰⣿⡟
⠈⣷⠸⣇⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡴⠞⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠀⠀⠉⣿⣿⡏⢀⣿⡟⠀
⠀⠹⣦⣿⣿⣿⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⠞⠋⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣤⣀⠀⠀⠀⠀⣼⣿⡿⢫⣿⣿⡁⠀
⠀⠀⠀⠙⣿⡿⣿⣿⣷⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡾⠁⠀⠀⠀⠀⠀⠀⠀⣀⣤⠶⠿⢯⡈⠙⣧⡀⠀⠀⣿⣄⣴⣿⣿⠉⠻⣦
⠀⠀⠀⠰⠿⠛⠛⠻⣿⣿⣿⣷⣦⣀⠀⠀⠀⠀⠀⠀⣴⠏⠀⠀⠀⠀⠀⠀⠀⣰⣿⠉⠀⠀⠀⠚⣷⠀⠘⡇⠀⠀⠀⠙⠛⠉⠁⠀⠀⠈
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣹⣿⣽⡿⣿⣷⣦⣀⠀⠀⢰⡟⠀⠀⠀⠀⠀⠀⠀⠀⣿⠽⣄⠀⠀⠀⣠⠟⠀⢀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠙⠻⣿⣿⣟⣷⣦⣼⡇⠀⠀⠀⠀⠀⠀⠀⠀⠛⢧⡉⠛⠛⠛⠁⠀⣠⡾⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⡟⢉⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠳⠶⠶⠶⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠈⠉⠉⠉⣻⣿⣇⡀⠀⠀⠀⠀⠀⣤⡶⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢷⣄⠀⣠⣾⡿⠁⠙⢷⣦⣦⣤⣴⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢀⣴⠶⣆⠀⠀⠀⣾⠉⢻⣿⣿⡀⠀⠀⢿⣿⢉⡿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢀⣿⠁⢠⡟⠀⠀⠀⣿⠀⠘⣯⠉⠃⠀⠀⠈⢁⣸⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣀⣼⡿⠀⠘⣷⠀⠀⠀⣿⠀⠀⢻⡶⠞⢛⡶⠚⢻⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢀⡾⠋⠁⣀⠀⠀⠈⠳⣄⠀⢸⡆⠀⠈⢷⣄⠟⢁⣠⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⡇⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢸⡇⠀⠀⠈⢻⡄⠀⠀⠘⢷⣤⣷⡀⠀⠀⠙⠛⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣧⠀⠀⠀⠀⣿⡀⠀⠀⠀⠈⢻⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣇⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢹⣄⠀⠀⢀⣿⠁⡀⠀⠀⠀⠀⠻⢷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣆⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠉⠛⠛⠛⠉⠻⣿⡦⠀⠀⠀⠀⠈⢻⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⡇⠀⠀⠀⠀⠀⠀
                ]],
                -- stylua: ignore
                keys = {
                    { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('aqfiles')" },
                    { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
                    {
                        icon = " ",
                        key = "s",
                        desc = "Load Session",
                        action = ":lua require('custom.session').load()",
                        enabled = function()
                            return require("custom.session").exists()
                        end,
                    },
                    { icon = "󱐥 ", key = "p", desc = "Plugins", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
                    { icon = " ", key = "q", desc = "Quit", action = ":qa" },
                },
            },
            sections = {
                { section = "header" },
                { header = "Show me your dreams." },
                { section = "keys", padding = 1 },
                { section = "startup" },
            },
        },

        bigfile = { enabled = true },

        input = { enabled = true },

        notifier = { enabled = true },

        quickfile = { enabled = true },

        words = {
            enabled = true,
            modes = { "n" },
        },

        explorer = { enabled = true },

        picker = {
            enabled = true,
            ui_select = true,
            formatters = {
                file = {
                    filename_first = true,
                },
            },
            icons = {
                kinds = require("config.icons").kinds,
            },
            previewers = {
                diff = {
                    style = "terminal",
                },
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
            layouts = {
                vscode = {
                    layout = {
                        backdrop = false,
                        row = 1,
                        width = 0.4,
                        min_width = 80,
                        height = 0.95,
                        border = "none",
                        box = "vertical",
                        {
                            win = "input",
                            height = 1,
                            border = true,
                            title = "{title} {live} {flags}",
                            title_pos = "center",
                        },
                        { win = "list", height = 0.4, border = "hpad" },
                        { win = "preview", title = "{preview}", border = true },
                    },
                },
            },
            sources = {
                aqfiles = {
                    layout = {
                        preset = "vscode",
                    },
                    multi = { "recent", "files" },
                    format = "file",
                    filter = { cwd = true },
                    hidden = true,
                    transform = "unique_file",
                    sort = { fields = { "score:desc", "idx" } },
                },
                files = {
                    show_empty = false,
                    exclude = { ".DS_Store" },
                    hidden = true,
                    layout = {
                        preset = "vscode",
                    },
                },
                buffers = {
                    layout = {
                        preset = "vscode",
                    },
                },
                grep = { hidden = true },
                grep_word = { hidden = true },
                git_log = git_ref_opts,
                git_log_file = git_ref_opts,
                git_branches = git_ref_opts,
                gh_pr = { live = false },
                gh_issue = { live = false },
                lsp_symbols = symbol_opts,
                explorer = { hidden = true },
            },
        },

        zen = {
            toggles = {
                dim = false,
            },
        },

        styles = {
            dashboard = {
                wo = { foldcolumn = "0" },
            },
            notification = {
                wo = { wrap = true },
            },
            lazygit = {
                width = 0,
                height = 0.99,
                keys = {
                    hide = {
                        "<c-q>",
                        "hide",
                        mode = "t",
                        expr = true,
                        desc = "Hide LazyGit",
                    },
                },
            },
            zen = {
                width = 0.65,
                backdrop = {
                    transparent = false,
                    blend = 95,
                },
            },
            terminal = {
                height = 12,
                wo = {
                    winbar = "",
                },
            },
        },
    },
    -- stylua: ignore
    keys = {
        { "<leader>go", function() Snacks.gitbrowse({ notify = false }) end, desc = "Git Browse", mode = { "n", "x" } },
        ---@diagnostic disable-next-line: missing-fields
        { "gy", function() Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false }) end, desc = "Git Browse (copy)", mode = { "n", "x" },  },
        { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
        { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
        { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },
        { "<leader>gD", function() Snacks.picker.git_diff() end, desc = "Git Diff" },
        { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
        { "<leader>gs", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
        { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
        { "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete Other Buffers" },
        { "<leader>ns",  function() Snacks.scratch({ ft = "markdown" }) end, desc = "Toggle Scratch Notes" },
        {
            "<leader>nt",
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
        { "<leader><leader>", function() Snacks.picker({ layout = { preset = "vscode" } }) end, desc = "Pick" },
        { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
        { "<leader>f", function() Snacks.picker.pick("aqfiles") end, desc = "Find Files Smart" },
        { "<leader>F", function() Snacks.picker.pick("aqfiles", { cwd = vim.fn.expand("%:h") }) end, desc = "Find Files Smart cwd" },
        { "g/", function() Snacks.picker.grep() end, desc = "Search String" },
        { "<leader>?", function() Snacks.picker.help() end, desc = "Help Pages" },
        { "<leader>su", function() Snacks.picker.undo() end, desc = "Undo Tree" },
        { "<leader>*", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
        { "<leader>pp", function() Snacks.toggle.profiler():toggle() end, desc = "Profile Picker" },
        { "<leader>se", function() Snacks.explorer() end, desc = "Search Explorer" },
        { "<leader>uz", function() Snacks.toggle.zen():toggle() end, desc = "Zen Mode" },
        { "<leader>us", function() Snacks.toggle.option("spell", { name = "Spelling" }):toggle() end, desc = "Toggle Spelling" },
        { "<leader>uD", function() Snacks.toggle.dim():toggle() end, desc = "Toggle Dim" },
        { "<leader>/", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
        { "<leader>sd", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
        { "<leader>sD", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
        { "z=", function() Snacks.picker.spelling() end, desc = "Spelling" },
        { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
        { "<leader>nh", function() Snacks.notifier.show_history() end, desc = "Notification History" },
        { "<leader>nn", function() Snacks.notifier.hide() end, desc = "No Notifications" },
        { "<leader>gi", function() Snacks.picker.gh_issue() end, desc = "GitHub Issues (open)" },
        { "<leader>gI", function() Snacks.picker.gh_issue({ state = "all" }) end, desc = "GitHub Issues (all)" },
        { "<leader>gp", function() Snacks.picker.gh_pr() end, desc = "GitHub Pull Requests (open)" },
        { "<leader>gP", function() Snacks.picker.gh_pr({ state = "all" }) end, desc = "GitHub Pull Requests (all)" },
        { "<c-\\>", function() Snacks.terminal() end, mode = { "n", "t" }, desc = "Terminal" },
        { "<leader>sf", function() Snacks.picker.git_files({ layout = { preset = "vscode" } }) end, desc = "Search Files (git-files)" },
        { "<leader>sh", function() Snacks.picker.highlights() end, desc = "Highlights" },
        { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
        { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
        { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
        { "<leader>sc", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
    },
}
