local M = {}

function M.truncateString(str, maxLen)
	if vim.fn.strchars(str) > maxLen then
		return vim.fn.strcharpart(str, 0, maxLen - 1) .. "…"
	else
		return str
	end
end

-- Custom snacks pickers
function M.pick_projects()
	local projects = {}
	local cmd = "fd --type d --hidden --follow --exclude .git --max-depth 1 --min-depth 1 . "
		.. vim.g.projects_dir
		.. "/Personal"

	local output = vim.fn.system(cmd)
	local exit_code = vim.v.shell_error

	if exit_code ~= 0 then
		vim.notify("Failed to list projects: " .. output, vim.log.levels.ERROR)
		return
	end

	for line in output:gmatch("[^\r\n]+") do
		table.insert(projects, line)
	end

	Snacks.picker.pick("personal_projects", {
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
			input = {
				keys = {
					---@diagnostic disable: assign-type-mismatch
					["<c-e>"] = { { "tcd", "picker_explorer" }, mode = { "n", "i" } },
					["<c-f>"] = { { "tcd", "picker_files" }, mode = { "n", "i" } },
					["<c-g>"] = { { "tcd", "picker_grep" }, mode = { "n", "i" } },
					["<c-r>"] = { { "tcd", "picker_recent" }, mode = { "n", "i" } },
					["<c-w>"] = { { "tcd" }, mode = { "n", "i" } },
					["<c-t>"] = {
						function(picker)
							vim.cmd("tabnew")
							picker:close()
							M.pick_projects()
						end,
						mode = { "n", "i" },
					},
				},
			},
		},
		confirm = "load_session",
	})
end

function M.action(action)
	return vim.lsp.buf.code_action({
		apply = true,
		context = {
			only = { action },
			diagnostics = {},
		},
	})
end

return M
