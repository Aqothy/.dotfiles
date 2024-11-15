return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			python = { "pylint" },
		}

		-- vim.api.nvim_create_autocmd({ "InsertLeave" }, {
		--   group = lint_augroup,
		--   callback = function()
		--     lint.try_lint()
		--   end,
		-- })

		vim.api.nvim_create_autocmd("VimLeave", {
			callback = function()
				vim.fn.system("eslint_d stop")
			end,
		})
	end,
}
