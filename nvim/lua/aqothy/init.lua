local is_vscode = vim.g.vscode
local lazy_autocmds = vim.fn.argc(-1) == 0

require("aqothy.config." .. (is_vscode and "vscode" or "options"))

if not is_vscode then
	_G.dd = function(...)
		Snacks.debug.inspect(...)
	end
	_G.bt = function()
		Snacks.debug.backtrace()
	end
	vim.print = _G.dd

	-- Load autocmds immediately if needed
	if not lazy_autocmds then
		require("aqothy.config.autocmds")
	end
end

require("aqothy.config.lazy")

if not is_vscode then
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

vim.deprecate = function() end
