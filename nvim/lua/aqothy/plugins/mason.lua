return {
    "mason-org/mason.nvim",
    build = ":MasonUpdate",
    keys = { { "<leader>tm", "<cmd>Mason<cr>", desc = "Mason" } },
    init = function()
        local is_windows = vim.fn.has("win32") ~= 0
        local sep = is_windows and "\\" or "/"
        local delim = is_windows and ";" or ":"
        vim.env.PATH = table.concat({ vim.fn.stdpath("data"), "mason", "bin" }, sep) .. delim .. vim.env.PATH
    end,
    opts = {
        ensure_installed = {
            -- LSP servers
            "lua-language-server",
            "clangd",
            "gopls",
            "texlab",
            "vtsls",
            "basedpyright",
            "ruff",

            -- Formatters/linters
            "stylua",
            "gofumpt",
            "goimports",
            "prettier",

            -- Dap
            "js-debug-adapter",
            "delve",
            "codelldb",

            -- Tools
            "tree-sitter-cli",
            "gomodifytags",
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
