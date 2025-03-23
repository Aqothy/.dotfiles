local M = {}

local fcs = vim.opt.fillchars:get()

function M.get_fold(lnum)
	if vim.fn.foldlevel(lnum) <= vim.fn.foldlevel(lnum - 1) then
		return " "
	end
	return vim.fn.foldclosed(lnum) == -1 and fcs.foldopen or fcs.foldclose
end

function M.render()
	return "%s%l " .. M.get_fold(vim.v.lnum) .. " "
end

vim.opt.statuscolumn = "%!v:lua.require'aqothy.config.statuscolumn'.render()"

return M
