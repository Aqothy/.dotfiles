return {
    "vim-test/vim-test",
    init = function()
        _G.AqTestStrat = function(cmd)
            local utils = require("custom.tasks")
            utils.spawn(cmd, { title = cmd })
        end

        vim.cmd([[
                function! AqTest(cmd)
                    call v:lua.AqTestStrat(a:cmd)
                endfunction

                let g:test#custom_strategies = {
                    \ 'aq_test': function('AqTest'),
                    \ }
                let g:test#strategy = 'aq_test'
            ]])
    end,
    keys = {
        { "<localleader>tf", "<cmd>TestFile<cr>", desc = "Run all tests in current file" },
        { "<localleader>tt", "<cmd>TestNearest<cr>", desc = "Run the test nearest to cursor" },
        { "<localleader>tr", "<cmd>TestLast<cr>", desc = "Run the last test" },
        { "<localleader>ts", "<cmd>TestSuite<cr>", desc = "Run the whole test suite" },
        { "<localleader>to", "<cmd>TestVisit<cr>", desc = "Go to last visited test file" },
    },
}
