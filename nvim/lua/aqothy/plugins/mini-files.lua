local filter_show = function(entry)
	return entry.fs_type ~= "file" or entry.name ~= ".DS_Store"
end

local filter_hide = function(entry)
	return filter_show(entry) and not vim.startswith(entry.name, ".")
end

return {
	"echasnovski/mini.files",
	-- custom lazy load for mini files
	init = function()
		vim.api.nvim_create_autocmd("BufEnter", {
			group = vim.api.nvim_create_augroup("mini_files_start", { clear = true }),
			desc = "Start mini files with a directory",
			once = true,
			callback = function()
				if package.loaded["mini.files"] then
					return
				else
					local stats = vim.uv.fs_stat(vim.fn.argv(0))
					if stats and stats.type == "directory" then
						require("mini.files")
						require("mini.files").open()
					end
				end
			end,
		})
	end,
	opts = function()
		return {
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
				filter = filter_show,
			},
			windows = {
				preview = true,
				width_focus = 30,
				width_preview = 30,
				width_nofocus = 30,
			},
		}
	end,
	keys = {
		{
			-- just like oil
			"-",
			function()
				require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
				require("mini.files").reveal_cwd()
			end,
			desc = "Open mini.files (Directory of Current File)",
		},
		{
			"<leader>ee",
			function()
				require("mini.files").open(vim.uv.cwd(), true)
			end,
			desc = "Open mini.files (Hide hidden files by default)",
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
		end

		local files_set_cwd = function()
			local cur_entry_path = mf.get_fs_entry().path
			local cur_directory = vim.fs.dirname(cur_entry_path)
			if cur_directory ~= nil then
				vim.fn.chdir(cur_directory)
			end
		end

		local yank_path = function()
			local path = (mf.get_fs_entry() or {}).path
			if path == nil then
				return vim.notify("Cursor is not on valid entry")
			end
			vim.fn.setreg(vim.v.register, path)
		end

		local ui_open = function()
			vim.ui.open(mf.get_fs_entry().path)
		end

		local group = vim.api.nvim_create_augroup("aqothy/mini_files", { clear = true })

		vim.api.nvim_create_autocmd("User", {
			group = group,
			pattern = "MiniFilesBufferCreate",
			callback = function(args)
				local buf_id = args.data.buf_id

				vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id, desc = "Toggle hidden files" })
				vim.keymap.set("n", "gc", files_set_cwd, { buffer = buf_id, desc = "Set cwd" })
				vim.keymap.set("n", "gx", ui_open, { buffer = buf_id, desc = "OS open" })
				vim.keymap.set("n", "gy", yank_path, { buffer = buf_id, desc = "Yank path" })
			end,
		})

		vim.api.nvim_create_autocmd("User", {
			group = group,
			pattern = "MiniFilesActionRename",
			callback = function(event)
				Snacks.rename.on_rename_file(event.data.from, event.data.to)
			end,
		})
	end,
}
