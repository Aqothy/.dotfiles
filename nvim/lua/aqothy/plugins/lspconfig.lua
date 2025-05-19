return {
	"neovim/nvim-lspconfig",
	event = "LazyFile",
	-- Mason has to load before lspconfig
	dependencies = {
		"mason-org/mason.nvim",
	},
	cmd = "LspInfo",
	keys = {
		{ "<leader>li", function() Snacks.picker.lsp_config() end, desc = "Lsp info" },
	},
	config = function()
		local handlers = require("aqothy.config.lsp-handlers")

		local params = {
			capabilities = handlers.capabilities,
		}

		-- global capabilities, lspconfig, peronal config in order of increasing priority
		vim.lsp.config("*", params)

		local settings = require("aqothy.config.lsp-settings")
		for lsp, opts in pairs(settings) do
			if opts.enabled ~= false then
				vim.lsp.config(lsp, opts)
				vim.lsp.enable(lsp)
			end
		end

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("aqothy/lsp_attach", { clear = true }),
			callback = function(ev)
				local client = vim.lsp.get_client_by_id(ev.data.client_id)

				if not client then
					return
				end

				handlers.on_attach(client, ev.buf)
			end,
		})
	end,
}
