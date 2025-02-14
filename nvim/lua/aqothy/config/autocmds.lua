local function augroup(name)
	return vim.api.nvim_create_augroup("aqothy_" .. name, { clear = true })
end
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	callback = function()
		(vim.hl or vim.highlight).on_yank({ timeout = 60 })
	end,
})

-- close some filetypes with <q>
autocmd("FileType", {
	group = augroup("close_with_q"),
	pattern = {
		"help",
		"git",
		"checkhealth",
		"qf",
		"vim",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.schedule(function()
			vim.keymap.set("n", "q", function()
				vim.cmd("close")
				pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
			end, {
				buffer = event.buf,
				silent = true,
				desc = "Quit buffer",
			})
		end)
	end,
})

-- check for spell in text filetypes
autocmd("FileType", {
	group = augroup("spell"),
	pattern = { "text", "tex", "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.spell = true
	end,
})

-- Fix conceallevel for json files
autocmd("FileType", {
	group = augroup("json_conceal"),
	pattern = { "json", "jsonc", "json5" },
	callback = function()
		vim.opt_local.conceallevel = 0
	end,
})

-- go to last loc when opening a buffer
autocmd("BufReadPost", {
	group = augroup("last_loc"),
	callback = function(event)
		local exclude = { "gitcommit" }
		local buf = event.buf
		if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].aqothy_last_loc then
			return
		end
		vim.b[buf].aqothy_last_loc = true
		local mark = vim.api.nvim_buf_get_mark(buf, '"')
		local lcount = vim.api.nvim_buf_line_count(buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
			vim.cmd("normal! zz")
		end
	end,
})

local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

vim.api.nvim_create_autocmd("LspProgress", {
	pattern = { "begin", "end" },
	group = augroup("lsp_progress_notify"),
	---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
		if not client or type(value) ~= "table" then
			return
		end
		local msg = value.title or ""
		local is_done = ev.data.params.value.kind == "end"
		vim.notify(msg, "info", {
			id = client.name .. client.id,
			title = client.name,
			opts = function(notif)
				notif.icon = is_done and " " or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
				notif.timeout = is_done and 3000 or 0
			end,
		})
	end,
})
