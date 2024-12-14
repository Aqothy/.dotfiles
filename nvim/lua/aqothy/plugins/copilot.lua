return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	lazy = false,
	config = function()
		require("copilot").setup({
			panel = {
				keymap = {
					jump_next = "<c-j>",
					jump_prev = "<c-k>",
					accept = "<c-y>",
					refresh = "r",
				},
			},
			suggestion = {
				enabled = true,
				auto_trigger = true,
				keymap = {
					accept = "<c-y>",
					next = "<c-j>",
					prev = "<c-k>",
					dismiss = "<c-h>",
				},
				filetypes = {
					yaml = true,
					markdown = true,
					help = false,
					["leetcode.nvim"] = false,
				},
				copilot_node_command = "node",
			},
		})
		vim.api.nvim_set_keymap(
			"n",
			"<C-s>",
			":lua require('copilot.suggestion').toggle_auto_trigger()<CR>",
			{ noremap = true, silent = true }
		)
	end,
}
