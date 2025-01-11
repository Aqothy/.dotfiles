return {
    "NeogitOrg/neogit",
    cmd = { "Neogit" },
    keys = {
        {
            "<leader>gs",
            function()
                require("neogit").open({ kind = "split" })
            end,
            desc = "Open Neogit",
        },
    },
    config = function()
        local neogit = require("neogit")
        neogit.setup({})
    end,
}
