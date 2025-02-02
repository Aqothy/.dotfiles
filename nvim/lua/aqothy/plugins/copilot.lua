return {
	"zbirenbaum/copilot.lua",
	build = ":Copilot auth",
	cmd = "Copilot",
	event = "BufReadPost",
	init = function()
		vim.g.copilot_enabled = 1
	end,
	config = function()
		require("copilot").setup({
			suggestion = {
				enabled = true,
				auto_trigger = true,
				keymap = {
					accept = "<M-l>",
					next = "<M-]>",
					prev = "<M-[>",
				},
			},
			filetypes = {
				["*"] = true,
			},
		})
	end,
}
