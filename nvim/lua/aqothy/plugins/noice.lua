return {
	"folke/noice.nvim",
	priority = 1000,
	event = "VeryLazy",
	-- dependencies = {
	-- "MunifTanjim/nui.nvim",
	-- },
	config = function()
		if vim.o.filetype == "lazy" then
			vim.cmd([[messages clear]])
		end

		require("noice").setup({
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			-- done by snacks
			notify = {
				enabled = false,
			},
			presets = {
				bottom_search = false,
				command_palette = false,
				long_message_to_split = true,
				lsp_doc_border = true,
			},
			routes = {
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "Agent service not initialized" },
						},
					},
					opts = { skip = true },
				},
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "%d+L, %d+B" },
							{ find = "; after #%d+" },
							{ find = "; before #%d+" },
							{ find = "^%d+ fewer lines$" },
							{ find = "^%d+ more lines$" },
							{ find = "^%d+ lines yanked$" },
							{ find = "^%d+ lines [<>]ed %d+ time$" },
						},
					},
					view = "mini",
				},
				-- 	{
				-- 		filter = {
				-- 			event = "lsp",
				-- 			any = {
				-- 				{ kind = "progress", find = "Validate documents" },
				-- 				{ kind = "progress", find = "Publish Diagnostics" },
				-- 			},
				-- 		},
				-- 		opts = { skip = true },
				-- 	},
				-- 	{
				-- 		filter = {
				-- 			any = {
				-- 				{ find = "clipboard: error: Nothing is copied" },
				-- 			},
				-- 		},
				-- 		opts = { skip = true },
				-- 	},
			},
		})
	end,
}
