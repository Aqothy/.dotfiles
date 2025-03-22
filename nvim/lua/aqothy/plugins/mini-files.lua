local filter_show = function(entry)
	return entry.fs_type ~= "file" or entry.name ~= ".DS_Store"
end

local filter_hide = function(entry)
	return filter_show(entry) and not vim.startswith(entry.name, ".")
end

local autocmd = vim.api.nvim_create_autocmd

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
			go_out_plus = "H",
		},
		content = {
			filter = filter_show,
		},
		windows = {
			preview = true,
			width_focus = 30,
			width_preview = 30,
			width_nofocus = 30,
		},
	},
	keys = {
		{
			-- just like oil
			"-",
			function()
				require("mini.files").open(vim.api.nvim_buf_get_name(0), false)
				require("mini.files").reveal_cwd()
			end,
			desc = "Open mini.files (Directory of Current File)",
		},
	},
	config = function(_, opts)
		local mf = require("mini.files")
		mf.setup(opts)

		local show_dotfiles = true

		local toggle_dotfiles = function()
			show_dotfiles = not show_dotfiles
			local new_filter = show_dotfiles and filter_show or filter_hide
			mf.refresh({ content = { filter = new_filter } })
			vim.notify("Dotfiles " .. (show_dotfiles and "shown" or "hidden"))
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
				local cur_target_window = require("mini.files").get_explorer_state().target_window
				if cur_target_window ~= nil then
					vim.api.nvim_win_call(cur_target_window, function()
						vim.cmd("belowright " .. direction .. " split")
						new_target_window = vim.api.nvim_get_current_win()
					end)

					require("mini.files").set_target_window(new_target_window)
					require("mini.files").go_in({ close_on_file = close_on_file })
				end
			end

			local desc = "Open in " .. direction .. " split"
			if close_on_file then
				desc = desc .. " and close"
			end
			vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
		end

		local group = vim.api.nvim_create_augroup("aqothy/mini_files", { clear = true })

		autocmd("User", {
			group = group,
			pattern = "MiniFilesBufferCreate",
			callback = function(args)
				local buf_id = args.data.buf_id

				vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id, desc = "Toggle hidden files" })
				vim.keymap.set("n", "cd", files_set_cwd, { buffer = buf_id, desc = "Set cwd" })
				vim.keymap.set("n", "gx", ui_open, { buffer = buf_id, desc = "OS open" })
				vim.keymap.set("n", "gy", yank_path, { buffer = buf_id, desc = "Yank path" })

				map_split(buf_id, "<C-w>s", "horizontal", false)
				map_split(buf_id, "<C-w>v", "vertical", false)
				map_split(buf_id, "<C-w>S", "horizontal", true)
				map_split(buf_id, "<C-w>V", "vertical", true)
			end,
		})

		autocmd("User", {
			desc = "Add rounded corners to minifiles window",
			group = group,
			pattern = "MiniFilesWindowOpen",
			callback = function(args)
				vim.api.nvim_win_set_config(args.data.win_id, { border = "rounded" })
			end,
		})

		autocmd("User", {
			group = group,
			pattern = { "MiniFilesActionRename", "MiniFilesActionMove" },
			callback = function(event)
				Snacks.rename.on_rename_file(event.data.from, event.data.to)
			end,
		})
	end,
}
