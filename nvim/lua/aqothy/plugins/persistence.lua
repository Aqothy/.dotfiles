return {
	"folke/persistence.nvim",
	lazy = false,
	opts = {},
	enabled = false,
	keys = {
		{
			"<leader>rs",
			function()
				require("persistence").load()
			end,
			desc = "Restore Session",
		},
		{
			"<leader>ss",
			function()
				require("persistence").select()
			end,
			desc = "Select Session",
		},
		{
			"<leader>qs",
			function()
				require("persistence").stop()
			end,
			desc = "Don't Save Current Session",
		},
	},
	init = function()
		vim.api.nvim_create_autocmd("VimEnter", {
			group = vim.api.nvim_create_augroup("restore_session", { clear = true }),
            once = true,
			callback = function()
				require("persistence").load()
			end,
			nested = true,
		})
	end,
}
