local leet_arg = "lc"
return {
	"kawre/leetcode.nvim",
	lazy = leet_arg ~= vim.fn.argv(0, -1),
	cmd = "Leet",
	keys = { { "<leader>le", ":Leet " } },
	config = function()
		require("leetcode").setup({
			arg = leet_arg,
			debug = false,

			-- dont really need injectors since no lsp is used
			-- injector = {
			--     ["cpp"] = {
			--         before = { '#include "/usr/local/bits/stdc++.h"', "using namespace std;" },
			--     },
			--     ["python3"] = {
			--         before = true,
			--     },
			-- },
			hooks = {
				["enter"] = function()
					pcall(vim.cmd, [[silent! Copilot disable]])
				end,
				["question_enter"] = function()
					-- Add an autocommand to wait for LSP to attach
					-- no lsp to simulate leetcode environment
					local group = vim.api.nvim_create_augroup("StopLSPOnAttach", { clear = true })
					vim.api.nvim_create_autocmd("LspAttach", {
						group = group,
						callback = function(args)
							local client = vim.lsp.get_client_by_id(args.data.client_id)
							client.stop()
						end,
					})
				end,
			},
			storage = {
				home = "~/Code/Personal/leetcode",
			},
			keys = {
				toggle = { "q", "<Esc>" },
			},
		})
	end,
}
