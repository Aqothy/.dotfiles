local function augroup(name)
	return vim.api.nvim_create_augroup("aqothy_" .. name, { clear = true })
end
local autocmd = vim.api.nvim_create_autocmd

-- Check if we need to reload the file when it changed
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = augroup("checktime"),
	callback = function()
		if vim.o.buftype ~= "nofile" then
			vim.cmd.checktime()
		end
	end,
})

-- Highlight on yank
autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	callback = function()
		(vim.hl or vim.highlight).on_yank({ timeout = 60 })
	end,
})

-- resize splits if window got resized
autocmd({ "VimResized" }, {
	group = augroup("resize_splits"),
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
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
				vim.cmd.close()
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
			vim.cmd.normal("zz")
		end
	end,
})

autocmd("FileType", {
	group = augroup("treesitter_folding"),
	callback = function(args)
		local bufnr = args.buf

		-- If LSP folding is already enabled, do nothing.
		if vim.b[bufnr].lsp_fold then
			return
		end

		if vim.b[bufnr].ts_folds == nil then
			vim.b[bufnr].ts_folds = pcall(vim.treesitter.get_parser, bufnr)
		end

		local win = vim.api.nvim_get_current_win()

		if vim.b[bufnr].ts_folds then
			vim.wo[win][0].foldmethod = "expr"
			vim.wo[win][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
		else
			vim.wo[win][0].foldmethod = "manual"
		end
	end,
})
