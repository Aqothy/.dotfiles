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

-- Ref: persisted nvim
local function make_fs_safe(text)
	return text:gsub("[\\/:]+", "%%")
end

local function is_subdirectory(parent, child)
	return vim.startswith(child, parent)
end

local function dirs_match(dir, dirs)
	dir = make_fs_safe(vim.fn.expand(dir))

	for _, search in ipairs(dirs) do
		if type(search) == "string" then
			search = make_fs_safe(vim.fn.expand(search))
			if is_subdirectory(search, dir) then
				return true
			end
		elseif type(search) == "table" then
			if search.exact then
				search = make_fs_safe(vim.fn.expand(search[1]))
				if dir == search then
					return true
				end
			end
		end
	end

	return false
end

-- Custom snacks picker to select and delete sessions
local function select_sessions()
	local ok, persistence = pcall(require, "persistence")
	if not ok then
		return
	end
	Snacks.picker.pick("Sessions", {
		finder = function()
			local items = {} ---@type snacks.picker.finder.Item[]
			local have = {}
			-- Ref: persistence nvim select function
			for _, session in ipairs(persistence.list()) do
				if vim.uv.fs_stat(session) then
					local session_name = session:sub(#session_state + 1, -5)
					local dirPath = unpack(vim.split(session_name, "%%", { plain = true }))
					dirPath = dirPath:gsub("%%", "/")
					if jit.os:find("Windows") then
						dirPath = dirPath:gsub("^(%w)/", "%1:/")
					end
					if not have[dirPath] then
						have[dirPath] = true
						items[#items + 1] = { file = dirPath, text = session, dir = true }
					end
				end
			end
			return items
		end,
		win = {
			preview = { minimal = true },
			input = {
				keys = {
					["<C-x>"] = { "delete_session", mode = { "i", "n" } },
				},
			},
		},
		layout = {
			preset = "vscode",
		},
		format = "file",
		actions = {
			["delete_session"] = {
				-- Basically snacks picker buf_del action
				function(picker)
					picker.preview:reset()
					for _, item in ipairs(picker:selected({ fallback = true })) do
						if item.text then
							vim.fn.delete(item.text)
						else
							vim.notify("No session found")
						end
					end
					picker.list:set_selected()
					picker.list:set_target()
					picker:find()
				end,
			},
		},
		confirm = function(_, item)
			if item._path then
				vim.fn.chdir(item._path)
				persistence.load()
			end
		end,
	})
end

return {
	"folke/persistence.nvim",
	lazy = is_file,
	event = "BufReadPre",
	enabled = true,
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
				select_sessions()
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
				require("persistence").start()
				vim.notify("Session started")
			end,
			desc = "Begin Session",
		},
	},
	config = function(_, opts)
		local persistence = require("persistence")
		persistence.setup(opts)

		local allowed_dirs = {
			vim.g.projects_dir .. "/Personal",
			vim.g.dotfiles,
		}

		-- If not in allow dir or is file
		if not dirs_match(cwd, allowed_dirs) or is_file then
			persistence.stop()
			return
		end

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

							pcall(vim.api.nvim_del_augroup_by_name, "restore_session")

							-- Schedule restoration for after window close completes
							vim.schedule(function()
								persistence.load()
							end)
						end,
					})
				end
			end,
		})
	end,
}
