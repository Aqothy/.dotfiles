return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	event = "VeryLazy",
	config = function()
		-- If treesitter is already loaded, we need to run config again for textobjects
		local Config = require("lazy.core.config")
		if Config.plugins["nvim-treesitter"] and Config.plugins["nvim-treesitter"]._.loaded then
			local plugin = require("lazy.core.config").spec.plugins["nvim-treesitter"]
			local Plugin = require("lazy.core.plugin")
			local opts = Plugin.values(plugin, "opts", false)
			require("nvim-treesitter.configs").setup({ textobjects = opts.textobjects })
		end

		-- When in diff mode, we want to use the default
		-- vim text objects c & C instead of the treesitter ones.
		local move = require("nvim-treesitter.textobjects.move") ---@type table<string,fun(...)>
		local configs = require("nvim-treesitter.configs")
		for name, fn in pairs(move) do
			if name:find("goto") == 1 then
				move[name] = function(q, ...)
					if vim.wo.diff then
						local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
						for key, query in pairs(config or {}) do
							if q == query and key:find("[%]%[][cC]") then
								vim.cmd("normal! " .. key)
								return
							end
						end
					end
					return fn(q, ...)
				end
			end
		end
	end,
}
