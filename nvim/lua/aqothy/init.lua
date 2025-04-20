local is_vscode = vim.g.vscode

require("aqothy.config." .. (is_vscode and "vscode" or "options"))

require("aqothy.config.lazy")

if not is_vscode then
	local lazy_autocmds = vim.fn.argc(-1) == 0

	-- Load autocmds immediately if needed
	if not lazy_autocmds then
		require("aqothy.config.autocmds")
	end

	vim.api.nvim_create_autocmd("User", {
		pattern = "VeryLazy",
		group = vim.api.nvim_create_augroup("Lazyload_Config", { clear = true }),
		callback = function()
			if lazy_autocmds then
				require("aqothy.config.autocmds")
			end
			require("aqothy.config.keymaps")
			require("aqothy.config.statusline")
		end,
	})
end
