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
		local filter_show = function(entry)
			return entry.fs_type ~= "file" or entry.name ~= ".DS_Store"
		end

		local filter_hide = function(entry)
			return filter_show(entry) and not vim.startswith(entry.name, ".")
		end

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
			custom_filters = {
				show = filter_show,
				hide = filter_hide,
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
		require("mini.files").setup(opts)

		local show_dotfiles = true

		local toggle_dotfiles = function()
			show_dotfiles = not show_dotfiles
			local new_filter = show_dotfiles and opts.custom_filters.show or opts.custom_filters.hide
			require("mini.files").refresh({ content = { filter = new_filter } })
		end

		local files_set_cwd = function()
			local cur_entry_path = require("mini.files").get_fs_entry().path
			local cur_directory = vim.fs.dirname(cur_entry_path)
			if cur_directory ~= nil then
				vim.fn.chdir(cur_directory)
			end
		end

		local files_group = vim.api.nvim_create_augroup("MiniFilesBuffer", { clear = true })
		vim.api.nvim_create_autocmd("User", {
			group = files_group,
			pattern = "MiniFilesBufferCreate",
			callback = function(args)
				local buf_id = args.data.buf_id

				vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id, desc = "Toggle hidden files" })
				vim.keymap.set("n", "gc", files_set_cwd, { buffer = args.data.buf_id, desc = "Set cwd" })
			end,
		})

		local rename_group = vim.api.nvim_create_augroup("MiniFilesRename", { clear = true })
		vim.api.nvim_create_autocmd("User", {
			group = rename_group,
			pattern = "MiniFilesActionRename",
			callback = function(event)
				Snacks.rename.on_rename_file(event.data.from, event.data.to)
			end,
		})
	end,
}
