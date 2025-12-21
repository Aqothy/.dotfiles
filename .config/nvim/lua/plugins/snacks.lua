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

local git_diff_opts = {
    layout = {
        preset = "diff",
    },
    formatters = {
        file = {
            filename_first = true,
        },
    },
    win = {
        input = {
            keys = {
                ["<c-i>"] = { "toggle_staged", mode = { "n", "i" } },
                ["<c-g>"] = { "toggle_group", mode = { "n", "i" } },
                ["<c-x>"] = { "git_restore", mode = { "n", "i" } },
                ["<c-r>"] = false,
            },
        },
        list = {
            keys = {
                ["<c-i>"] = { "toggle_staged" },
                ["<c-g>"] = { "toggle_group" },
                ["<c-x>"] = { "git_restore" },
            },
        },
        preview = {
            keys = {
                ["<tab>"] = { "list_down" },
                ["<s-tab>"] = { "list_up" },
            },
        },
    },
    actions = {
        toggle_staged = function(p)
            local opts = p.opts
            if opts.staged == nil then
                opts.staged = false
            else
                opts.staged = nil
            end
            p:find()
        end,
        toggle_group = function(p)
            local opts = p.opts
            if opts.group == nil then
                opts.group = true
            else
                opts.group = not opts.group
            end
            p:find()
        end,
    },
}

local symbol_filter = {
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
        },
    },
}

return {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    opts = {
        dashboard = {
            preset = {
                -- stylua: ignore
                keys = {
                    { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('aqfiles')" },
                    { icon = " ", key = "s", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
                    {
                        icon = " ",
                        key = "g",
                        desc = "Git",
                        action = ":lua Snacks.lazygit()",
                        enabled = function()
                            return Snacks.git.get_root() ~= nil
                        end,
                    },
                    { icon = " ", key = "t", desc = "New Tab", action = ":tabnew" },
                    { icon = "󱐥 ", key = "p", desc = "Plugins", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
                    { icon = " ", key = "q", desc = "Quit", action = ":qa" },
                },
            },
            sections = {
                { text = string.format("NVIM %s", vim.version()), align = "center", padding = 2 },
                { section = "keys", padding = 1 },
            },
        },
        bigfile = { enabled = true },

        input = { enabled = true },

        notifier = {
            enabled = true,
            sort = { "added" },
            top_down = false,
            margin = { top = 0, right = 1, bottom = 1 },
        },

        quickfile = { enabled = true },

        words = {
            enabled = true,
            modes = { "n" },
        },

        picker = {
            enabled = true,
            ui_select = true,
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
                        ["<Down>"] = { "history_forward", mode = { "i", "n" } },
                        ["<Up>"] = { "history_back", mode = { "i", "n" } },
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
                        width = 0.5,
                        min_width = 60,
                        height = 0.95,
                        border = "none",
                        box = "vertical",
                        {
                            win = "input",
                            height = 1,
                            border = "rounded",
                            title = "{title} {live} {flags}",
                            title_pos = "center",
                        },
                        { win = "list", height = 0.4, border = "none" },
                        { win = "preview", title = "{preview}", border = "rounded" },
                    },
                },
                default = {
                    fullscreen = true,
                    layout = {
                        backdrop = false,
                        box = "horizontal",
                        {
                            box = "vertical",
                            {
                                win = "input",
                                height = 1,
                                border = "rounded",
                                title = "{title} {live} {flags}",
                                title_pos = "center",
                            },
                            { win = "list", border = "none" },
                        },
                        { win = "preview", title = "{preview}", border = true, width = 0.6 },
                    },
                },
                diff = {
                    fullscreen = true,
                    layout = {
                        backdrop = false,
                        box = "horizontal",
                        {
                            box = "vertical",
                            width = 0.25,
                            min_width = 20,
                            {
                                win = "input",
                                height = 1,
                                border = "rounded",
                                title = "{title} {live} {flags}",
                                title_pos = "center",
                            },
                            { win = "list", border = "none" },
                        },
                        { win = "preview", title = "{preview}", border = true },
                    },
                },
                vertical = {
                    fullscreen = true,
                    layout = {
                        border = true,
                        title = "{title} {live} {flags}",
                        title_pos = "center",
                        box = "vertical",
                        { win = "input", height = 1, border = "bottom" },
                        { win = "list", border = "none" },
                        { win = "preview", title = "{preview}", height = 0.6, border = "top" },
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
                git_diff = git_diff_opts,
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
                grep = {
                    hidden = true,
                },
                grep_word = {
                    hidden = true,
                },
                git_log = git_ref_opts,
                git_log_file = git_ref_opts,
                git_branches = git_ref_opts,
                gh_diff = git_diff_opts,
                gh_pr = { live = false },
                gh_issue = { live = false },
                lsp_symbols = symbol_filter,
                treesitter = symbol_filter,
            },
        },

        zen = {
            toggles = {
                dim = false,
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
                    hide = {
                        "<c-[>",
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
        },
    },
    -- stylua: ignore
    keys = {
        { "<leader>go", function() Snacks.gitbrowse({ notify = false }) end, desc = "Git Browse", mode = { "n", "x" } },
        ---@diagnostic disable-next-line: missing-fields
        { "<leader>gy", function() Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false }) end, desc = "Git Browse (copy)", mode = { "n", "x" },  },
        { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
        { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
        { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },
        { "<leader>hd", function() Snacks.picker.git_diff() end, desc = "Git Diff" },
        { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
        { "<leader>gs", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
        { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
        { "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete Other Buffers" },
        { "<leader>ns",  function() Snacks.scratch({ ft = "markdown" }) end, desc = "Toggle Scratch Notes" },
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
        { "<leader><leader>", function() Snacks.picker({ layout = { preset = "vscode" } }) end, desc = "Pick" },
        { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
        { "<leader>f", function() Snacks.picker.pick("aqfiles") end, desc = "Find Files Smart" },
        { "<leader>F", function() Snacks.picker.pick("aqfiles", { cwd = vim.fn.expand("%:h") }) end, desc = "Find Files Smart cwd" },
        { "<leader>s", function() Snacks.picker.grep() end, desc = "Grep" },
        { "<leader>?", function() Snacks.picker.help() end, desc = "Help Pages" },
        { "<leader>u", function() Snacks.picker.undo({ layout = { preset = "diff" } }) end, desc = "undo tree" },
        { "<leader>*", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
        { "<leader>pp", function() Snacks.toggle.profiler():toggle() end, desc = "Profiler Picker" },
        { "<leader>zz", function() Snacks.toggle.zen():toggle() end, desc = "Zen Mode" },
        { "<leader>/", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
        { "<leader>ld", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
        { "<leader>lD", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
        { "z=", function() Snacks.picker.spelling() end, desc = "Spelling" },
        { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
        { "<leader>nh", function() Snacks.notifier.show_history() end, desc = "Notification History" },
        { "<leader>nn", function() Snacks.notifier.hide() end, desc = "No Notifications" },
        { "<leader>gi", function() Snacks.picker.gh_issue() end, desc = "GitHub Issues (open)" },
        { "<leader>gI", function() Snacks.picker.gh_issue({ state = "all" }) end, desc = "GitHub Issues (all)" },
        { "<leader>gp", function() Snacks.picker.gh_pr() end, desc = "GitHub Pull Requests (open)" },
        { "<leader>gP", function() Snacks.picker.gh_pr({ state = "all" }) end, desc = "GitHub Pull Requests (all)" },
        { "gO", function() Snacks.picker.treesitter() end, desc = "Treesitter symbols" },
    },
}
