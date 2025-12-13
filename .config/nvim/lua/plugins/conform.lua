return {
    "stevearc/conform.nvim",
    cmd = "ConformInfo",
    keys = {
        {
            "gq",
            function()
                require("conform").format({ async = true })
            end,
            mode = { "n", "x" },
            desc = "Format Buffer or Selection",
        },
    },
    opts = {
        log_level = vim.log.levels.OFF,
        notify_on_error = false,
        quiet = true,
        formatters_by_ft = {
            -- npm install -g prettier
            javascript = { "prettier" },
            typescript = { "prettier" },
            javascriptreact = { "prettier" },
            typescriptreact = { "prettier" },
            css = { "prettier" },
            html = { "prettier" },
            json = { "prettier" },
            yaml = { "prettier" },
            markdown = { "prettier" },
            -- brew install stylua
            lua = { "stylua" },
            -- go install mvdan.cc/gofumpt@latest
            -- go install golang.org/x/tools/cmd/goimports@latest
            go = { "goimports", "gofumpt" },
            -- comes with mac
            swift = { "swift" },
            python = { name = "ruff", lsp_format = "prefer" },
            -- For filetypes without a formatter, use trim and lsp:
            ["_"] = { "trim_whitespace", "trim_newlines", lsp_format = "last" },
        },
        default_format_opts = {
            lsp_format = "fallback",
            timeout_ms = 500,
        },
    },
}
