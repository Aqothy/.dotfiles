local function augroup(name)
	return vim.api.nvim_create_augroup("aqothy" .. name, { clear = true })
end
local autocmd = vim.api.nvim_create_autocmd

-- Create an autogroup for autosave
--local autosave_augroup = vim.api.nvim_create_augroup("Autosave", { clear = true })
--
--vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
--	group = autosave_augroup,
--	pattern = "*",
--	callback = function()
--		vim.cmd("silent! write") -- Automatically save the current buffer
--	end,
--})

-- Check if we need to reload the file when it changed
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = augroup("checktime"),
	callback = function()
		if vim.o.buftype ~= "nofile" then
			vim.cmd("checktime")
		end
	end,
})

-- Highlight on yank
autocmd("TextYankPost", {
	group = augroup("HighlightYank"),
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 40,
		})
	end,
})

-- close some filetypes with <q>
autocmd("FileType", {
	group = augroup("close_with_q"),
	pattern = {
		"gitsigns-blame",
		"help",
		"checkhealth",
		"qf",
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

-- resize splits if window got resized
autocmd("VimResized", {
	group = augroup("resize_splits"),
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
})

-- wrap and check for spell in text filetypes
autocmd("FileType", {
	group = augroup("wrap_spell"),
	pattern = { "text", "tex", "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.wrap = true
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

-- Auto create dir when saving a file, in case some intermediate directory does not exist
autocmd({ "BufWritePre" }, {
	group = augroup("auto_create_dir"),
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- remove dashboard when opening quickfix
autocmd("FileType", {
	group = augroup("Remove_Dashboard"),
	pattern = { "qf" },
	once = true,
	callback = function()
		if vim.api.nvim_buf_is_valid(1) then
			Snacks.bufdelete({ buf = 1 })
		end
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
		vim.b[buf].aqothy_loc = true
		local mark = vim.api.nvim_buf_get_mark(buf, '"')
		local lcount = vim.api.nvim_buf_line_count(buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

vim.cmd([[
  aunmenu PopUp
  anoremenu PopUp.Inspect     <cmd>Inspect<CR>
  anoremenu PopUp.Definition  <cmd>lua require('fzf-lua').lsp_definitions()<CR>
  anoremenu PopUp.References  <cmd>lua require('fzf-lua').lsp_references()<CR>
]])

autocmd("MenuPopup", {
	pattern = "*",
	group = augroup("nvim_popupmenu"),
	desc = "Custom PopUp Setup",
	callback = function()
		vim.cmd([[
      amenu disable PopUp.Definition
      amenu disable PopUp.References
    ]])

		if vim.lsp.get_clients({ bufnr = 0 })[1] then
			vim.cmd([[
        amenu enable PopUp.Definition
        amenu enable PopUp.References
      ]])
		end
	end,
})
