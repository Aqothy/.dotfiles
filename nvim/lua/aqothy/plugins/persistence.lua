local session_state = vim.fn.stdpath("state") .. "/sessions/"

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
	lazy = false,
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
			end,
			desc = "Don't Save Current Session",
		},
	},
	config = function(_, opts)
		local persistence = require("persistence")
		persistence.setup(opts)

		local allowed_dirs = {
			vim.g.projects_dir .. "/Personal",
			vim.g.dotfiles,
		}

		-- If not in allow dir then stop session and don't load session either
		if not dirs_match(vim.fn.getcwd(), allowed_dirs) then
			persistence.stop()
			return
		end

		vim.api.nvim_create_autocmd("VimEnter", {
			group = vim.api.nvim_create_augroup("restore_session", { clear = true }),
			once = true,
			nested = true,
			callback = function()
				local load = false
				-- If no args
				if vim.fn.argc() == 0 then
					load = true
				-- If args is dir
				elseif vim.fn.argc() == 1 then
					local dir = vim.fn.expand(vim.fn.argv(0))
					if dir == "." then
						dir = vim.fn.getcwd()
					end
					if vim.fn.isdirectory(dir) ~= 0 then
						load = true
					end
				end

				if load then
					persistence.load()
				end
			end,
		})
	end,
}
