return {
    "mason-org/mason.nvim",
    build = ":MasonUpdate",
    cmd = { "Mason", "MasonInstall" },
    keys = { { "<leader>tm", "<cmd>Mason<cr>", desc = "Mason" } },
    opts_extend = { "ensure_installed" },
    init = function()
        local is_windows = vim.fn.has("win32") ~= 0
        local sep = is_windows and "\\" or "/"
        local delim = is_windows and ";" or ":"
        vim.env.PATH = table.concat({ vim.fn.stdpath("data"), "mason", "bin" }, sep) .. delim .. vim.env.PATH
    end,
    opts = {
        ensure_installed = {
            -- LSP servers
            "css-lsp",
            "tailwindcss-language-server",
            "lua-language-server",
            "basedpyright",
            "clangd",
            "gopls",
            "eslint-lsp",
            "texlab",
            "vtsls",
            "emmet-language-server",
            "ruff",
            "bash-language-server",
            "json-lsp",

            -- Formatters/linters
            "stylua",
            "prettier",
            "gofumpt",
            "goimports",
            "latexindent",

            -- Dap
            "js-debug-adapter",
            "delve",
            "codelldb",
        },

        ui = {
            icons = {
                package_installed = "",
                package_pending = "",
                package_uninstalled = "",
            },
        },

        log_level = vim.log.levels.OFF,

        PATH = "skip",
    },
    config = function(_, opts)
        require("mason").setup(opts)

        local mr = require("mason-registry")

        mr.refresh(function()
            for _, tool in ipairs(opts.ensure_installed) do
                local p = mr.get_package(tool)
                if not p:is_installed() then
                    vim.notify("Installing " .. tool)
                    p:install()
                end
            end
        end)
    end,
}
