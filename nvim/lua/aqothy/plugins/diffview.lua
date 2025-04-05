return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
	keys = {
		{
			"<leader>gd",
			function()
				vim.cmd("Diffview" .. (require("diffview.lib").get_current_view() == nil and "Open" or "Close"))
			end,
			desc = "Toggle Diffview",
		},
		{ "<leader>gf", "<cmd>DiffviewFileHistory<cr>", desc = "File History" },
		{ "<leader>gm", "<cmd>DiffviewOpen origin/main..HEAD<cr>", desc = "Diff Main" },
	},
	opts = function()
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
