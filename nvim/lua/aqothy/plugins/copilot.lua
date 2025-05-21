return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "LazyFile",
	keys = {
		{
			"<leader>tc",
			function()
				Snacks.toggle({
					name = "Copilot",
					get = function()
						return not require("copilot.client").is_disabled()
					end,
					set = function(state)
						vim.cmd("Copilot " .. (state and "enable" or "disable"))
					end,
				}):toggle()
			end,
			desc = "Toggle Copilot",
		},
	},
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
			dotenv = false,
			["*"] = true,
		},
		server_opts_overrides = {
			settings = {
				telemetry = {
					telemetryLevel = "off",
				},
			},
		},
	},
}
