return {
    {
        "echasnovski/mini.icons",
        event = "VeryLazy",
        opts = {
            file = {
                ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
                [".eslintrc.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
                [".prettierrc"] = { glyph = "", hl = "MiniIconsPurple" },
                ["eslint.config.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
                ["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
                ["tsconfig.json"] = { glyph = "", hl = "MiniIconsAzure" },
                ["yarn.lock"] = { glyph = "", hl = "MiniIconsBlue" },
            },
            filetype = {
                env = { glyph = "", hl = "MiniIconsYellow" },
                go = { glyph = "", hl = "MiniIconsAzure" },
            },
        },
        init = function()
            package.preload["nvim-web-devicons"] = function()
                require("mini.icons").mock_nvim_web_devicons()
                return package.loaded["nvim-web-devicons"]
            end
        end,
    },
    {
        "nvim-mini/mini.files",
        opts = {
            options = {
                permanent_delete = false,
            },
            mappings = {
                go_in_plus = "<CR>",
                go_out_plus = "-",
            },
            content = {
                filter = function(entry)
                    return not (entry.fs_type == "file" and entry.name == ".DS_Store")
                end,
            },
            windows = {
                width_focus = 30,
                width_preview = 30,
                preview = true,
            },
        },
        keys = {
            {
                "<leader>ee",
                function()
                    MiniFiles.open(vim.uv.cwd())
                end,
                desc = "Open mini.files (cwd)",
            },
            {
                -- just like oil
                "-",
                function()
                    local path = vim.api.nvim_buf_get_name(0)

                    if path ~= "" and vim.uv.fs_stat(path) then
                        MiniFiles.open(path, false)
                    else
                        MiniFiles.open(vim.uv.cwd(), false)
                    end
                end,
                desc = "Open MiniFiles (Directory of Current File)",
            },
        },
        config = function(_, opts)
            local mf = require("mini.files")
            mf.setup(opts)

            local show_dotfiles = true
            local filter_show = opts.content.filter
            local filter_hide = function(entry)
                return filter_show(entry) and not vim.startswith(entry.name, ".")
            end

            local toggle_dotfiles = function()
                show_dotfiles = not show_dotfiles
                local new_filter = show_dotfiles and filter_show or filter_hide
                mf.refresh({ content = { filter = new_filter } })
            end

            local map_split = function(buf_id, lhs, direction)
                local rhs = function()
                    local cur_target = mf.get_explorer_state().target_window

                    if cur_target == nil or mf.get_fs_entry().fs_type == "directory" then
                        return
                    end

                    local new_target = vim.api.nvim_win_call(cur_target, function()
                        vim.cmd(direction .. " split")
                        return vim.api.nvim_get_current_win()
                    end)

                    mf.set_target_window(new_target)
                    mf.go_in({ close_on_file = true })
                end

                local desc = "Split " .. direction
                vim.keymap.set("n", lhs, rhs, { buf = buf_id, desc = desc })
            end

            local yank_path = function()
                local path = (mf.get_fs_entry() or {}).path
                if path == nil then
                    return vim.notify("Cursor is not on valid entry")
                end
                vim.fn.setreg(vim.v.register, path)
                vim.notify("Yanked path: " .. path)
            end

            local set_cwd = function()
                local path = (mf.get_fs_entry() or {}).path
                if path == nil then
                    return vim.notify("Cursor is not on valid entry")
                end
                local dir = vim.fs.dirname(path)
                vim.fn.chdir(dir, "tabpage")
                vim.notify("Set CWD to: " .. dir)
            end

            local ui_open = function()
                local path = (mf.get_fs_entry() or {}).path
                if path then
                    vim.ui.open(path)
                end
            end

            local nmap = function(buf_id, lhs, rhs, desc)
                vim.keymap.set("n", lhs, rhs, { buf = buf_id, desc = desc })
            end

            local autocmd = vim.api.nvim_create_autocmd
            local group = vim.api.nvim_create_augroup("aqothy/mini_files", { clear = true })

            autocmd("User", {
                group = group,
                pattern = "MiniFilesBufferCreate",
                callback = function(ev)
                    local buf = ev.data.buf_id

                    nmap(buf, "g.", toggle_dotfiles, "Toggle hidden files")
                    nmap(buf, "gx", ui_open, "OS open")
                    nmap(buf, "gy", yank_path, "Yank path")
                    nmap(buf, "cd", set_cwd, "Set CWD")

                    map_split(buf, "<C-w>s", "horizontal")
                    map_split(buf, "<C-w>v", "vertical")
                    map_split(buf, "<C-t>", "tab")
                end,
            })

            autocmd("User", {
                group = group,
                pattern = "MiniFilesExplorerOpen",
                callback = function()
                    mf.set_bookmark("w", vim.uv.cwd(), { desc = "Working directory" })
                end,
            })

            autocmd("User", {
                group = group,
                pattern = { "MiniFilesActionRename", "MiniFilesActionMove" },
                callback = function(ev)
                    Snacks.rename.on_rename_file(ev.data.from, ev.data.to)
                    vim.schedule(function()
                        mf.close()
                    end)
                end,
            })

            autocmd("User", {
                group = group,
                pattern = "MiniFilesActionDelete",
                callback = function(ev)
                    local from = ev.data.to
                    local result = vim.system({ "trash", from }, { text = true }):wait()
                    if result.code ~= 0 then
                        vim.notify(
                            "Failed to trash file: " .. from .. "\n" .. (result.stderr or ""),
                            vim.log.levels.ERROR
                        )
                    end
                end,
            })
        end,
    },
    {
        "echasnovski/mini.hipatterns",
        event = "LazyFile",
        keys = {
            {
                "<leader>uh",
                function()
                    ---@diagnostic disable-next-line
                    MiniHipatterns.toggle()
                end,
                desc = "Toggle Hipatterns",
            },
        },
        opts = function()
            local hi = require("mini.hipatterns")

            local function hi_words(words, group, extmark_opts)
                local pattern = vim.tbl_map(function(x)
                    return "%f[%w]()" .. vim.pesc(x) .. "()%f[%W]"
                end, words)
                return { pattern = pattern, group = group, extmark_opts = extmark_opts }
            end

            return {
                highlighters = {
                    fixme = hi_words({ "FIXME", "FIX" }, "MiniHipatternsFixme"),
                    hack = hi_words({ "HACK" }, "MiniHipatternsHack"),
                    todo = hi_words({ "TODO" }, "MiniHipatternsTodo"),
                    note = hi_words({ "NOTE" }, "MiniHipatternsNote"),
                    hex_color = hi.gen_highlighter.hex_color(),
                },
            }
        end,
    },
    {
        "nvim-mini/mini.ai",
        keys = {
            { "a", mode = { "x", "o" } },
            { "i", mode = { "x", "o" } },
        },
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        opts = function()
            local ai = require("mini.ai")
            local gen_spec = ai.gen_spec
            local ts_arg = gen_spec.treesitter({
                a = { "@parameter.outer", "@attribute.outer" },
                i = { "@parameter.inner", "@attribute.inner" },
            })
            local fb_arg = gen_spec.argument()
            local ts_call = gen_spec.treesitter({ a = "@call.outer", i = "@call.inner" })
            local fb_call = gen_spec.function_call()
            return {
                n_lines = 500,
                silent = true,
                mappings = {
                    around_next = "",
                    inside_next = "",
                    around_last = "",
                    inside_last = "",
                    goto_left = "",
                    goto_right = "",
                },
                custom_textobjects = {
                    o = gen_spec.treesitter({
                        a = { "@conditional.outer", "@loop.outer" },
                        i = { "@conditional.inner", "@loop.inner" },
                    }),
                    f = gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
                    c = gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
                    a = function(...)
                        local ok, res = pcall(ts_arg, ...)
                        if not ok or vim.tbl_isempty(res) then
                            return fb_arg
                        end
                        return res
                    end,
                    u = function(...)
                        local ok, res = pcall(ts_call, ...)
                        if not ok or vim.tbl_isempty(res) then
                            return fb_call
                        end
                        return res
                    end,
                    U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
                    S = {
                        {
                            "%u[%l%d]+%f[^%l%d]",
                            "%f[^%s%p][%l%d]+%f[^%l%d]",
                            "^[%l%d]+%f[^%l%d]",
                            "%f[^%s%p][%w]+%f[^%w]",
                            "^[%w]+%f[^%w]",
                        },
                        "^().*()$",
                    }, -- subwords
                    t = "",
                },
            }
        end,
    },
    {
        "nvim-mini/mini.operators",
        keys = {
            { "cx", desc = "Exchange operator" },
            { "X", mode = "x", desc = "Exchange operator visual" },
            { "gR", mode = { "n", "x" }, desc = "Replace operator" },
            { "gm", mode = { "n", "x" }, desc = "Multiply operator" },
        },
        opts = {
            evaluate = {
                prefix = "",
            },
            exchange = {
                prefix = "",
            },
            multiply = {
                prefix = "gm",
            },
            replace = {
                prefix = "gR",
            },
            sort = {
                prefix = "",
            },
        },
        config = function(_, opts)
            local mo = require("mini.operators")
            mo.setup(opts)
            mo.make_mappings("exchange", { textobject = "cx", line = "cxx", selection = "X" })
        end,
    },
}
