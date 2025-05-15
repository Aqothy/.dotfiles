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

	-- For windows
	-- local projects_dir = vim.g.projects_dir .. "/Personal"
	-- local cmd = "powershell -Command \"Get-ChildItem -Path '"
	-- 	.. projects_dir
	-- 	.. "' -Directory | Select-Object -ExpandProperty FullName\""

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

-- optimized treesitter foldexpr
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

function M.hide_tmux(state, disable)
	if not vim.env.TMUX then
		return
	end
	if disable then
		local function get_tmux_opt(option)
			local option_raw = vim.fn.system([[tmux show -w ]] .. option)
			if option_raw == "" then
				option_raw = vim.fn.system([[tmux show -g ]] .. option)
			end
			local opt = vim.split(vim.trim(option_raw), " ")[2]
			return opt
		end
		state.status = get_tmux_opt("status")
		state.pane = get_tmux_opt("pane-border-status")

		vim.fn.system([[tmux set -w pane-border-status off]])
		vim.fn.system([[tmux set status off]])
		vim.fn.system([[tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z]])
	else
		if type(state.pane) == "string" then
			vim.fn.system(string.format([[tmux set -w pane-border-status %s]], state.pane))
		else
			vim.fn.system([[tmux set -uw pane-border-status]])
		end
		vim.fn.system(string.format([[tmux set status %s]], state.status))
		vim.fn.system([[tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z]])
	end
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
