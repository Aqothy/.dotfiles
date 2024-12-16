return {
	"zbirenbaum/copilot.lua",
	-- lazy = false,
	event = "VeryLazy",
	config = function()
		require("copilot").setup({
			panel = {
				keymap = {
					jump_next = "<C-j>",
					jump_prev = "<C-k>",
					accept = "<C-enter>",
					refresh = "r",
				},
			},
			suggestion = {
				enabled = true,
				auto_trigger = true,
				keymap = {
					accept = "<C-enter>",
					next = "<C-j>",
					prev = "<C-k>",
					dismiss = "<C-h>",
				},
				filetypes = {
					yaml = true,
					markdown = true,
					help = false,
					["leetcode.nvim"] = false,
				},
			},
		})
		vim.api.nvim_set_keymap(
			"n",
			"<c-s>",
			":lua require('copilot.suggestion').toggle_auto_trigger()<CR>",
			{ noremap = true, silent = true }
		)
	end,
}
