return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
	keys = {
		{
			"<leader>gd",
			function()
				vim.cmd("Diffview" .. (require("diffview.lib").get_current_view() == nil and "Open" or "Close"))
			end,
			desc = "Toggle Diff view",
		},
		{ "<leader>gf", "<cmd>DiffviewFileHistory<cr>", desc = "File history" },
		{ "<leader>gm", "<cmd>DiffviewOpen origin/main..HEAD<cr>", desc = "Diff main" },
	},
	opts = function()
		require("diffview.ui.panel").Panel.default_config_float.border = "rounded"
		return {
			view = {
				merge_tool = {
					layout = "diff4_mixed",
				},
				file_history = {
					layout = "diff2_horizontal",
				},
			},
		}
	end,
}
