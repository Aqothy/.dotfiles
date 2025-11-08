return {
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = {
            enable_afterquote = false,
        },
        config = function(_, opts)
            require("nvim-autopairs").setup(opts)
            local Rule = require("nvim-autopairs.rule")
            local npairs = require("nvim-autopairs")

            npairs.add_rule(Rule("$", "$", "tex"))
        end,
    },
    {
        "windwp/nvim-ts-autotag",
        ft = {
            "html",
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
        },
        opts = {},
    },
}
