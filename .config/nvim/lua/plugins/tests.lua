return {
    "vim-test/vim-test",
    init = function()
        if vim.g.vscode then
            vim.g["test#strategy"] = "neovim_vscode"
            return
        end

        vim.g["test#custom_strategies"] = {
            aq_test = function(cmd)
                require("custom.tasks").spawn(cmd, { title = cmd })
            end,
        }
        vim.g["test#strategy"] = "aq_test"
    end,
    keys = {
        { "<localleader>tf", "<cmd>TestFile<cr>", desc = "Run all tests in current file" },
        { "<localleader>tt", "<cmd>TestNearest<cr>", desc = "Run the test nearest to cursor" },
        { "<localleader>tr", "<cmd>TestLast<cr>", desc = "Run the last test" },
        { "<localleader>ts", "<cmd>TestSuite<cr>", desc = "Run the whole test suite" },
        { "<localleader>to", "<cmd>TestVisit<cr>", desc = "Go to last visited test file" },
    },
}
