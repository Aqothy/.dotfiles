return {
	"zbirenbaum/copilot.lua",
	build = ":Copilot auth",
	cmd = "Copilot",
	event = "BufReadPost",
	config = function()
		require("copilot").setup({
			suggestion = {
				enabled = true,
				auto_trigger = true,
				keymap = {
					accept = "<M-l>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
			},
			filetypes = {
				["*"] = true,
			},
		})
		Snacks.toggle({
			name = "Copilot",
			get = function()
				return not require("copilot.client").is_disabled()
			end,
			set = function(state)
				if state then
					require("copilot.command").enable()
				else
					require("copilot.command").disable()
				end
			end,
		}):map("<leader>tc")
	end,
}
