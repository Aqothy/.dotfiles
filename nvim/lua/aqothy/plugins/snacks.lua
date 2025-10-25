local git_options = {
    actions = {
        ["diffview"] = function(picker)
            local currentCommit = picker:current().commit
            if currentCommit then
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
                ["<c-o>"] = { "diffview", desc = "Diffview this commit", mode = { "n", "i" } },
                ["<c-y>"] = { "copy_commit", desc = "Copy commit", mode = { "n", "i" } },
            },
        },
    },
}

-- { lua pattern, rg --glob alternate files pattern }
local alternate_patterns = {
    { "(.*)_test%.go$", "%1.go" },
    { "(.*)%.go$", "%1_test.go" },
    { "(.*)%.cpp$", "%1.hpp" },
    { "(.*)%.hpp$", "%1.cpp" },
}

return {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    opts = {
        bigfile = { enabled = true },

        input = { enabled = true },

        notifier = { enabled = true, sort = { "added" } },

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
            formatters = {
                file = {
                    filename_first = true,
                },
            },
            layout = {
                preset = "default",
            },
            layouts = {
                default = {
                    layout = {
                        backdrop = false,
                        width = 0.5,
                        min_width = 80,
                        height = 0.95,
                        row = 1,
                        border = "none",
                        box = "vertical",
                        {
                            win = "input",
                            height = 1,
                            border = "rounded",
                            title = "{title} {live} {flags}",
                            title_pos = "center",
                        },
                        { win = "list", height = 15, border = "none" },
                        { win = "preview", title = "{preview}", border = "rounded" },
                    },
                },
            },
            sources = {
                aqfiles = {
                    layout = {
                        hidden = { "preview" },
                    },
                    multi = { "recent", "files" },
                    format = "file",
                    filter = { cwd = true },
                    hidden = true,
                    transform = "unique_file",
                    sort = { fields = { "score:desc", "idx" } },
                },
                files = {
                    layout = {
                        hidden = { "preview" },
                    },
                    hidden = true,
                    show_empty = false,
                    exclude = { ".DS_Store" },
                    supports_live = false,
                },
                buffers = {
                    layout = {
                        hidden = { "preview" },
                    },
                    filter = {
                        filter = function(item)
                            return vim.bo[item.buf].buftype == ""
                        end,
                    },
                },
                grep = {
                    hidden = true,
                },
                grep_word = {
                    hidden = true,
                },
                git_log = git_options,
                git_log_file = git_options,
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
                width = vim.o.columns,
                height = vim.o.lines,
            },
            zen = {
                width = 120,
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
        { "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete Other Buffers" },
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
        {
            "<leader><tab>",
            function()
                local rel = vim.fn.expand("%:.")
                local cwd = vim.uv.cwd()
                local name = vim.fn.expand("%:t:r")
                local filename = vim.fn.expand("%:t")
                if name == "" or rel == "" then
                    return
                end

                local alternate_glob
                for _, mapping in ipairs(alternate_patterns) do
                    local replaced, count = filename:gsub(mapping[1], mapping[2], 1)
                    if count > 0 then
                        alternate_glob = "**/" .. replaced
                        break
                    end
                end

                alternate_glob = alternate_glob or ("**/*" .. name .. "*")

                Snacks.picker.pick("files", {
                    auto_confirm = true,
                    finder = function(opts, ctx)
                        return require("snacks.picker.source.proc").proc({
                            opts,
                            {
                                cmd = "rg",
                                args = { "--files", "--no-messages", "--color", "never", "-g", "!.git", "--hidden", "--glob", alternate_glob, "--glob", "!" .. rel },
                                notify = false,
                                transform = function(item)
                                    item.cwd = cwd
                                    item.file = item.text
                                end,
                            },
                        }, ctx)
                    end,
                })
            end,
            desc = "Alternate Files",
        },
        { "<leader>.", function() Snacks.picker.resume() end, desc = "Resume Last Picker" },
        { "<leader><leader>", function() Snacks.picker({ layout = { hidden = { "preview" }, } }) end, desc = "Pick" },
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
        { "z=", function() Snacks.picker.spelling() end, desc = "Spelling" },
        { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
        { "<leader>nh", function() Snacks.notifier.show_history() end, desc = "Notification History" },
        { "<leader>nn", function() Snacks.notifier.hide() end, desc = "No Notifications" },
    },
}
