local M = {}

function M.truncateString(str, maxLen)
	if vim.fn.strchars(str) > maxLen then
		return vim.fn.strcharpart(str, 0, maxLen - 1) .. "…"
	else
		return str
	end
end

-- Ref: persisted nvim
function M.make_fs_safe(text)
	return text:gsub("[\\/:]+", "%%")
end

function M.is_subdirectory(parent, child)
	return vim.startswith(child, parent)
end

function M.dirs_match(dir, dirs)
	dir = M.make_fs_safe(vim.fn.expand(dir))

	for _, search in ipairs(dirs) do
		if type(search) == "string" then
			search = M.make_fs_safe(vim.fn.expand(search))
			if M.is_subdirectory(search, dir) then
				return true
			end
		elseif type(search) == "table" then
			if search.exact then
				search = M.make_fs_safe(vim.fn.expand(search[1]))
				if dir == search then
					return true
				end
			end
		end
	end

	return false
end

-- Custom snacks pickers

function M.pick_projects()
	local projects = {}
	local cmd = "fd --type d --max-depth 1 --min-depth 1 . " .. vim.g.projects_dir .. "/Personal"

	local output = vim.fn.system(cmd)
	local exit_code = vim.v.shell_error

	if exit_code ~= 0 then
		vim.notify("Failed to list projects: " .. output, vim.log.levels.ERROR)
		return
	end

	for line in output:gmatch("[^\r\n]+") do
		table.insert(projects, line)
	end

	Snacks.picker.pick("Projects", {
		finder = function()
			local dirs = {}
			for _, dir in ipairs(projects) do
				dirs[#dirs + 1] = { text = dir, file = dir, dir = true }
			end
			return dirs
		end,
		format = "file",
		win = {
			preview = { minimal = true },
		},
		confirm = "load_session",
	})
end

function M.select_sessions(session_state)
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
							vim.schedule(function()
								vim.fn.delete(item.text)
							end)
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
		confirm = function(picker, item)
			if item._path then
				picker:close()
				vim.schedule(function()
					vim.fn.chdir(item._path)
					persistence.load()
				end)
			end
		end,
	})
end

function M.foldexpr()
	local buf = vim.api.nvim_get_current_buf()
	if vim.b[buf].ts_folds == nil then
		-- as long as we don't have a filetype, don't bother
		-- checking if treesitter is available (it won't)
		if vim.bo[buf].filetype == "" then
			return "0"
		end

		vim.b[buf].ts_folds = pcall(vim.treesitter.get_parser, buf)
	end
	return vim.b[buf].ts_folds and vim.treesitter.foldexpr() or "0"
end

return M
