return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
	keys = {
		{ "<leader>gf", "<cmd>DiffviewFileHistory<cr>", desc = "File history" },
		{ "<leader>gm", "<cmd>DiffviewOpen origin/main..HEAD<cr>", desc = "Diff main" },
		{
			"<leader>gd",
			function()
				if next(require("diffview.lib").views) == nil then
					vim.cmd("DiffviewOpen")
				else
					vim.cmd("DiffviewClose")
				end
			end,
			desc = "Diff view",
		},
	},
	opts = function()
		require("diffview.ui.panel").Panel.default_config_float.border = "rounded"
		return {}
	end,
}
