return {
    {
        "echasnovski/mini.icons",
        lazy = true,
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
                use_as_default_explorer = true,
                permanent_delete = false,
            },
            mappings = {
                go_in = "l",
                go_in_plus = "<CR>",
                go_out = "h",
                go_out_plus = "-",
            },
            content = {
                filter = function(entry)
                    return entry.fs_type ~= "file" or entry.name ~= ".DS_Store"
                end,
            },
            windows = {
                width_nofocus = 25,
                preview = true,
            },
        },
        ---@diagnostic disable-next-line
        lazy = vim.fn.isdirectory(vim.fn.argv(0)) ~= 1,
        keys = {
            {
                "<leader>ee",
                function()
                    MiniFiles.open(vim.uv.cwd(), true)
                end,
                desc = "Open mini.files (cwd)",
            },
            {
                -- just like oil
                "-",
                function()
                    local bufname = vim.api.nvim_buf_get_name(0)
                    local path = vim.fn.fnamemodify(bufname, ":p")

                    if path and vim.uv.fs_stat(path) then
                        MiniFiles.open(bufname, false)
                        MiniFiles.reveal_cwd()
                    else
                        vim.notify("No valid path found", vim.log.levels.WARN)
                    end
                end,
                desc = "Open MiniFiles (Directory of Current File)",
            },
        },
        config = function(_, opts)
            local mf = require("mini.files")
            mf.setup(opts)

            local show_dotfiles = true

            local filter_hide = function(entry)
                return mf.config.content.filter(entry) and not vim.startswith(entry.name, ".")
            end

            local toggle_dotfiles = function()
                show_dotfiles = not show_dotfiles
                local new_filter = show_dotfiles and mf.config.content.filter or filter_hide
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
                vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
            end

            local yank_path = function()
                local path = (mf.get_fs_entry() or {}).path
                if path == nil then
                    return vim.notify("Cursor is not on valid entry")
                end
                vim.fn.setreg(vim.v.register, path)
                vim.notify("Yanked path: " .. path)
            end

            local function entry_dir(entry)
                if not entry or not entry.path then
                    return nil
                end

                return entry.fs_type == "directory" and entry.path or vim.fs.dirname(entry.path)
            end

            local files_set_cwd = function()
                local dir = entry_dir(mf.get_fs_entry())
                if dir == nil then
                    return vim.notify("Cursor is not on valid entry")
                end

                vim.fn.chdir(dir, "tabpage")
                vim.notify("Set CWD to: " .. dir)
            end

            local ui_open = function()
                vim.ui.open(mf.get_fs_entry().path)
            end

            local nmap = function(buf_id, lhs, rhs, desc)
                vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
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
                    nmap(buf, "cg", files_set_cwd, "Set CWD")

                    map_split(buf, "<C-w>s", "horizontal")
                    map_split(buf, "<C-w>v", "vertical")
                    map_split(buf, "<C-t>", "tab")
                end,
            })

            autocmd("User", {
                group = group,
                pattern = "MiniFilesExplorerOpen",
                callback = function()
                    local current_dir = entry_dir(mf.get_fs_entry())
                    mf.set_bookmark("w", vim.fn.getcwd(), { desc = "Working directory" })
                    if current_dir then
                        mf.set_bookmark("c", current_dir, { desc = "Current file directory" })
                    end
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
                    local ok, ret = pcall(vim.fn.system, { "trash", from })
                    if not ok or vim.v.shell_error ~= 0 then
                        vim.notify("Failed to trash file: " .. from .. "\n" .. ret, vim.log.levels.ERROR)
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
}
