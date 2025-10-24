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
                dotenv = { glyph = "", hl = "MiniIconsYellow" },
                go = { glyph = "", hl = "MiniIconsAzure" },
                kitty = { glyph = "󰄛", hl = "MiniIconsOrange" },
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
                use_as_default_explorer = false,
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
                width_focus = 20,
                width_nofocus = 20,
                width_preview = 20,
                preview = true,
            },
        },
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

            local yank_path = function()
                local path = (mf.get_fs_entry() or {}).path
                if path == nil then
                    return vim.notify("Cursor is not on valid entry")
                end
                vim.fn.setreg(vim.v.register, path)
                vim.notify("Yanked path: " .. path)
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
                callback = function(args)
                    local buf_id = args.data.buf_id

                    nmap(buf_id, "g.", toggle_dotfiles, "Toggle hidden files")
                    nmap(buf_id, "gx", ui_open, "OS open")
                    nmap(buf_id, "gy", yank_path, "Yank path")
                    nmap(buf_id, "q", function()
                        show_dotfiles = true
                        mf.close()
                    end, "Close this window")
                    MiniFiles.set_bookmark("w", vim.fn.getcwd(), { desc = "Working directory" })
                end,
            })

            autocmd("User", {
                group = group,
                pattern = { "MiniFilesActionRename", "MiniFilesActionMove" },
                callback = function(event)
                    Snacks.rename.on_rename_file(event.data.from, event.data.to)
                    vim.schedule(function()
                        mf.close()
                    end)
                end,
            })
        end,
    },
    {
        "echasnovski/mini.hipatterns",
        event = "LazyFile",
        keys = {
            {
                "<leader>th",
                function()
                    MiniHipatterns.toggle()
                end,
                desc = "Toggle MiniHipatterns",
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
                    fixme = hi_words({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
                    hack = hi_words({ "HACK", "Hack", "hack" }, "MiniHipatternsHack"),
                    todo = hi_words({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
                    note = hi_words({ "NOTE", "Note", "note" }, "MiniHipatternsNote"),
                    hex_color = hi.gen_highlighter.hex_color(),
                },
            }
        end,
    },
}
