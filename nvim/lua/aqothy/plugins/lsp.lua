return {
  "neovim/nvim-lspconfig",
  --  event = {
  --    "BufReadPre",
  --    "BufNewFile",
  --    "CmdlineEnter",
  --  },
  dependencies = {
    {
      "hrsh7th/cmp-nvim-lsp",
      "williamboman/mason-lspconfig.nvim",
      "williamboman/mason.nvim",
      --		"WhoIsSethDaniel/mason-tool-installer.nvim",
    },
  },
  config = function()
    local lspconfig = require("lspconfig")

    local mason = require("mason")

    -- import mason-lspconfig
    local mason_lspconfig = require("mason-lspconfig")

    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    --		local mason_tool_installer = require("mason-tool-installer")

    mason.setup()

    -- Keymaps for LSP
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }

        vim.keymap.set("n", "<leader>ld", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions
        vim.keymap.set("n", "<leader>lt", vim.lsp.buf.type_definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "]d", function()
          vim.diagnostic.jump({ count = 1 })
        end, opts)
        vim.keymap.set("n", "[d", function()
          vim.diagnostic.jump({ count = -1 })
        end, opts)
      end,
    })

    vim.keymap.set("n", "<leader>ef", vim.diagnostic.open_float, { desc = "Open diagnostic float" })

    -- Diagnostics Configuration
    vim.diagnostic.config({
      virtual_text = true,
      underline = true,
      -- update_in_insert = false,
      float = {
        focusable = true,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
      },
    })

    -- LSP server setup
    local capabilities = vim.tbl_deep_extend(
      "force",
      {},
      vim.lsp.protocol.make_client_capabilities(),
      cmp_nvim_lsp.default_capabilities()
    )

    mason_lspconfig.setup({
      -- list of servers for mason to install
      ensure_installed = {
        "html",
        "cssls",
        "tailwindcss",
        "lua_ls",
        "emmet_ls",
        "pyright",
        "clangd",
        "gopls",
        "jdtls",
        "texlab",
        "eslint",
        -- "typescript-language-server", -- just manually download on mason, dk why its broken
      },

      handlers = {
        function(server_name)
          lspconfig[server_name].setup({
            capabilities = capabilities,
          })
        end,
        ["lua_ls"] = function()
          lspconfig["lua_ls"].setup({
            capabilities = capabilities,
            settings = {
              Lua = {
                diagnostics = {
                  globals = { "vim" },
                },
                completion = {
                  callSnippet = "Replace",
                },
              },
            },
          })
        end,
        ["pyright"] = function()
          lspconfig["pyright"].setup({
            capabilities = capabilities,
            settings = {
              python = {
                analysis = {
                  -- TODO: It would be nice to understand this better and turn these back on someday.
                  reportMissingTypeStubs = false,
                  typeCheckingMode = "off",
                },
              },
            },
          })
        end,
        ["emmet_ls"] = function()
          -- configure emmet language server
          lspconfig["emmet_ls"].setup({
            capabilities = capabilities,
            filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss" },
          })
        end,

      }
    })
    --		mason_tool_installer.setup({
    --			ensure_installed = {
    --				"prettier", -- prettier formatter
    --				"stylua", -- lua formatter
    --				"black", -- python formatter
    --				"eslint_d",
    --				"latexindent",
    --				"clang-format",
    --				"gofumpt",
    --				"goimports-reviser",
    --				"golines",
    --			},
    --		})
  end,
}
