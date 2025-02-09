return {
	"neovim/nvim-lspconfig",
	event = { "LazyFile" },
	cmd = { "LspInstall", "LspUninstall", "LspInfo" },
	config = function()
		local lspconfig = require("lspconfig")
		local handlers = require("aqothy.config.lsp-handlers")

		local params = {
			capabilities = handlers.capabilities,
		}

		local settings = require("aqothy.config.lsp-settings")
		for lsp, opts in pairs(settings) do
			if opts.enabled ~= false then
				lspconfig[lsp].setup(vim.tbl_deep_extend("force", params, opts))
			end
		end

		vim.api.nvim_create_autocmd("LspAttach", {
			-- dont clear the group
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
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
