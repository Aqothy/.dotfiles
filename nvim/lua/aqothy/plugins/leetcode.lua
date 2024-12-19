return {
	"kawre/leetcode.nvim",
	cmd = "Leet",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
	},
	keys = { { "<leader>le", ":Leet " } },
	config = function()
		require("leetcode").setup({
			injector = {
				["cpp"] = {
					before = { '#include "/usr/local/bits/stdc++.h"', "using namespace std;" },
				},
				["python3"] = {
					before = true,
				},
			},
			hooks = {
				["enter"] = function()
					pcall(vim.cmd, [[silent! Copilot disable]])
				end,
			},
			storage = {
				home = "~/Code/Personal/leetcode",
			},
		})
		vim.keymap.set("n", "<leader>le", ":Leet ")
	end,
}
