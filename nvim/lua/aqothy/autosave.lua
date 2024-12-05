-- Create an autogroup for autosave
local autosave_augroup = vim.api.nvim_create_augroup("Autosave", { clear = true })

vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
	group = autosave_augroup,
	pattern = "*",
	callback = function()
		vim.cmd("silent! write") -- Automatically save the current buffer
	end,
})
