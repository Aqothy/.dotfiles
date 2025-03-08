local is_vscode = vim.g.vscode
local lazy_autocmds = vim.fn.argc(-1) == 0

require("aqothy.config." .. (is_vscode and "vscode" or "options"))

if not is_vscode then
	-- Load autocmds immediately if there are arguments
	if not lazy_autocmds then
		require("aqothy.config.autocmds")
	end

	-- Setup lazy loading
	vim.api.nvim_create_autocmd("User", {
		pattern = "VeryLazy",
		group = vim.api.nvim_create_augroup("LazyLoad", { clear = true }),
		callback = function()
			if lazy_autocmds then
				require("aqothy.config.autocmds")
			end
			require("aqothy.config.keymaps")
			require("aqothy.config.statusline")
		end,
	})
end

require("aqothy.config.lazy")
