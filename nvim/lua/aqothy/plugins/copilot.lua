return {
	"zbirenbaum/copilot.lua",
	build = ":Copilot auth",
	cmd = "Copilot",
	event = "BufReadPost",
	opts = function()
		return {
			panel = {
				enabled = false,
			},
			suggestion = {
				enabled = true,
				auto_trigger = true,
				debounce = 30,
				keymap = {
					accept = "<M-a>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
			},
			workspace_folders = {
				"~/Code/Personal",
			},
			copilot_model = "gpt-4o-copilot",
			filetypes = {
				["*"] = true,
			},
		}
	end,
}
