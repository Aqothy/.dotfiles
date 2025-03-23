return {
	"zbirenbaum/copilot.lua",
	build = ":Copilot auth",
	cmd = "Copilot",
	event = "InsertEnter",
	opts = {
		panel = {
			enabled = false,
		},
		suggestion = {
			enabled = true,
			auto_trigger = true,
			keymap = {
				accept = "<M-a>",
				next = "<M-]>",
				prev = "<M-[>",
				dismiss = "<C-]>",
			},
		},
		copilot_model = "gpt-4o-copilot",
		filetypes = {
			["*"] = true,
		},
	},
}
