return {
    "echasnovski/mini.files",
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

        local files_set_cwd = function()
            local cur_entry_path = mf.get_fs_entry().path
            local cur_directory = vim.fs.dirname(cur_entry_path)
            if cur_directory ~= nil then
                vim.fn.chdir(cur_directory)
            end
            vim.notify("CWD set to " .. cur_directory)
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

        local map_split = function(buf_id, lhs, direction, close_on_file)
            local rhs = function()
                local new_target_window
                local cur_target_window = mf.get_explorer_state().target_window
                if cur_target_window ~= nil then
                    vim.api.nvim_win_call(cur_target_window, function()
                        vim.cmd("belowright " .. direction .. " split")
                        new_target_window = vim.api.nvim_get_current_win()
                    end)

                    mf.set_target_window(new_target_window)
                    mf.go_in({ close_on_file = close_on_file })
                end
            end

            local desc = "Open in " .. direction .. " split"
            if close_on_file then
                desc = desc .. " and close"
            end
            vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
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
                nmap(buf_id, "cd", files_set_cwd, "Set cwd")
                nmap(buf_id, "gx", ui_open, "OS open")
                nmap(buf_id, "gy", yank_path, "Yank path")
                nmap(buf_id, "q", function()
                    show_dotfiles = show_dotfiles and false or true
                    mf.close()
                end, "Close this window")

                map_split(buf_id, "<C-w>s", "horizontal", false)
                map_split(buf_id, "<C-w>v", "vertical", false)
                map_split(buf_id, "<C-w>S", "horizontal", true)
                map_split(buf_id, "<C-w>V", "vertical", true)
            end,
        })

        autocmd("User", {
            group = group,
            pattern = { "MiniFilesActionRename", "MiniFilesActionMove" },
            callback = function(event)
                vim.schedule(function()
                    mf.close()
                end)
                Snacks.rename.on_rename_file(event.data.from, event.data.to)
            end,
        })
    end,
}
