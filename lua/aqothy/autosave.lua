-- Create an augroup for autosave
local autosave_augroup = vim.api.nvim_create_augroup("Autosave", { clear = true })

-- Autosave and format on InsertLeave and TextChanged events
vim.api.nvim_create_autocmd({ "InsertLeave", "BufEnter" }, {
	group = autosave_augroup,
	pattern = "*",
	callback = function()
		require("lint").try_lint()
		vim.cmd("silent! write") -- Automatically save the current buffer
	end,
})
