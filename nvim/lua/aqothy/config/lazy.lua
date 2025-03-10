local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- custom lazyfile event so no need to write these 3 events everytime
local Event = require("lazy.core.handler.event")
local lazy_file_events = { "BufReadPost", "BufNewFile", "BufWritePre" }
Event.mappings.LazyFile = { id = "LazyFile", event = lazy_file_events }
Event.mappings["User LazyFile"] = Event.mappings.LazyFile

local is_vscode = vim.g.vscode
local lazy_autocmds = vim.fn.argc(-1) == 0

require("aqothy.config." .. (is_vscode and "vscode" or "options"))

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		{
			import = "aqothy.plugins",
			cond = function()
				return not is_vscode
			end,
		},
		{
			import = "aqothy.vscode",
			cond = function()
				return is_vscode
			end,
		},
	},
	install = { colorscheme = { "gruvbox" } },
	ui = {
		border = "rounded",
	},
	defaults = {
		lazy = false,
		version = false, -- always use the latest git commit
		-- version = "*", -- try installing the latest stable version for plugins that support semver
	},
	-- automatically check for plugin updates
	checker = { enabled = false },
	change_detection = { notify = false },
	rocks = {
		enabled = false,
	},
	performance = {
		rtp = {
			-- disable some rtp plugins
			disabled_plugins = {
				"gzip",
				-- "matchit",
				-- "matchparen",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})

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
