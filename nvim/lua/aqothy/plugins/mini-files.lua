return {
	"echasnovski/mini.files",
	-- custom lazy load for mini files
	init = function()
		vim.api.nvim_create_autocmd("BufEnter", {
			group = vim.api.nvim_create_augroup("mini-files-start", { clear = true }),
			desc = "Start mini files with a directory",
			once = true,
			callback = function()
				if package.loaded["mini.files"] then
					return
				end

				-- Ensure there are arguments (argv) and check if the first argument is a directory
				local argv = vim.fn.argv(0)
				if argv and vim.uv.fs_stat(argv) and vim.uv.fs_stat(argv).type == "directory" then
					require("mini.files")
					require("mini.files").open(argv, true)
				end
			end,
		})
	end,
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
			desc = "Open mini.files (cwd, hide dotfiles by default)",
		},
	},
	config = function(_, opts)
		-- copy pasted straight from lazyvim docs
		require("mini.files").setup(opts)

		local show_dotfiles = true

		local filter_show = function(_)
			return true
		end

		local filter_hide = function(fs_entry)
			return not vim.startswith(fs_entry.name, ".")
		end

		local toggle_dotfiles = function()
			show_dotfiles = not show_dotfiles
			local new_filter = show_dotfiles and filter_show or filter_hide
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

				vim.keymap.set("n", "<C-g>", toggle_dotfiles, { buffer = buf_id, desc = "Toggle hidden files" })

				-- close with <ESC> as well as q
				vim.keymap.set("n", "<ESC>", function()
					require("mini.files").close()
				end, { buffer = buf_id })

				--write with :w
				vim.api.nvim_set_option_value("buftype", "acwrite", { buf = buf_id })
				vim.api.nvim_buf_set_name(buf_id, string.format("mini.files-%s", vim.loop.hrtime()))
				vim.api.nvim_create_autocmd("BufWriteCmd", {
					buffer = buf_id,
					callback = function()
						require("mini.files").synchronize()
					end,
				})

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
