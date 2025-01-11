return {
	"sontungexpt/sttusline",
	branch = "table_version",
	config = function()
		require("sttusline").setup({
			statusline_color = "#32312f",
			disabled = {
				filetypes = {
					"",
					"qf",
					"help",
					"lazy",
					"NeogitStatus",
					"NeogitCommitView",
					"noice",
					"snacks_dashboard",
					"snacks_terminal",
					"trouble",
					"fugitive",
					"leetcode.nvim",
					"mason",
					"terminal",
					"fzf",
					"netrw",
					"undotree",
					"undotreeDiff",
					"gitsigns-blame",
					"minifiles",
					"DiffviewFiles",
					"gitcommit",
				},
				buftypes = {
					"terminal",
				},
			},
			components = {
				"os-uname",
				"mode",
				"filename",
				"git-branch",
				"git-diff",
				"%=",
				"diagnostics",
				"lsps-formatters",
				"copilot",
				"indent",
				"encoding",
				"filesize",
				{
					-- Macro recording component
					name = "macro",
					update_group = "macro_update",
					event = { "RecordingEnter", "RecordingLeave" }, -- Update on recording events
					user_event = { "VeryLazy" }, -- No user events needed
					timing = false, -- No interval-based updates
					lazy = true, -- Load lazily
					space = {},
					configs = {},
					padding = { left = 1, right = 1 }, -- Add padding to the component
					colors = { fg = "#ff8700" }, -- Highlight for the macro component
					init = function() end, -- Initialization (if needed)
					update = function()
						-- Get the current recording register
						local recording_register = vim.fn.reg_recording()
						if recording_register and recording_register ~= "" then
							return string.format("Recording @%s", recording_register) -- Show the macro register
						end
						return "" -- No macro recording, return empty string
					end,
					condition = function()
						-- Only display the component if a macro is being recorded
						return vim.fn.reg_recording() ~= nil and vim.fn.reg_recording() ~= ""
					end,
					on_highlight = function() end, -- Additional highlight logic (if needed)
				},
			},
		})
	end,
}
