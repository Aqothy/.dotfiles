local session_state = vim.fn.stdpath("state") .. "/sessions/"

local is_file = true
local load = false
local cwd = vim.fn.getcwd()
local arg_count = vim.fn.argc()

if arg_count == 0 then
	load = true
	is_file = false
elseif arg_count == 1 then
	local arg = vim.fn.expand(vim.fn.argv(0))

	-- Handle current directory case
	if arg == "." then
		load = true
		is_file = false
	-- Handle directory case
	elseif vim.fn.isdirectory(arg) ~= 0 then
		-- Convert to absolute path if it's relative
		local abs_path = vim.fn.fnamemodify(arg, ":p:h")
		vim.fn.chdir(abs_path)
		cwd = abs_path
		load = true
		is_file = false
	end
end

-- Don't lazy when is file so don't load, keymap will auto setup plugin so no need to call it, can just notify
return {
	"folke/persistence.nvim",
	lazy = is_file,
	-- enabled = false,
	opts = {
		dir = session_state,
	},
	keys = {
		{
			"<leader>rr",
			function()
				require("persistence").load()
			end,
			desc = "Restore Session",
		},
		{
			"<leader>ss",
			function()
				require("aqothy.config.utils").select_sessions(session_state)
			end,
			desc = "Select Session",
		},
		{
			"<leader>qs",
			function()
				require("persistence").stop()
				vim.notify("Session stopped")
			end,
			desc = "Don't Save Current Session",
		},
		{
			"<leader>bs",
			function()
				vim.notify("Session started")
			end,
			desc = "Begin Session",
		},
	},
	config = function(_, opts)
		local persistence = require("persistence")

		-- local utils = require("aqothy.config.utils")

		persistence.setup(opts)

		-- local allowed_dirs = {
		-- 	vim.g.projects_dir .. "/Personal",
		-- 	vim.g.dotfiles,
		-- }

		-- If not in allow dir or is file
		-- if not utils.dirs_match(cwd, allowed_dirs) then
		-- 	persistence.stop()
		-- 	return
		-- end

		local group = vim.api.nvim_create_augroup("restore_session", { clear = true })

		vim.api.nvim_create_autocmd("VimEnter", {
			group = group,
			nested = true,
			once = true,
			callback = function()
				if not load then
					return
				end

				local ok, lazy_view = pcall(require, "lazy.view")

				-- If the Lazy window is visible, hold onto it for later.
				if ok and not lazy_view.visible() then
					persistence.load()
					vim.cmd.normal("zz")
					return
				end

				-- Track the lazy view window
				local lazy_view_win = lazy_view.view.win

				if lazy_view_win then
					-- Make sure don't load session til lazy view is closed (for when lazy is downloading plugins)
					vim.api.nvim_create_autocmd("WinClosed", {
						group = group,
						callback = function(event)
							if event.match ~= tostring(lazy_view_win) then
								return
							end

							vim.api.nvim_clear_autocmds({ group = group })

							-- Schedule restoration for after window close completes
							vim.schedule(function()
								persistence.load()
								vim.cmd.normal("zz")
							end)
						end,
					})
				end
			end,
		})
	end,
}
