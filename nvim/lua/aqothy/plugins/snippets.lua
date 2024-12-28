return {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    event = "InsertEnter",
    config = function()
        local ls = require("luasnip")
        -- require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets/" })

        --tester
        local s = ls.snippet
        local t = ls.text_node
        local i = ls.insert_node
        local c = ls.choice_node

        -- Add snippets for Lua
        ls.add_snippets("lua", {
            -- Function snippet
            s("func", {
                t("function "),
                i(1, "function_name"),
                t("("),
                i(2, "args"),
                t(")"),
                t({ "", "    " }),
                i(3, "-- body"),
                t({ "", "end" }),
            }),

            -- Choice node snippet
            s("choice", {
                t("Choose: "),
                c(1, {
                    t("Option 1"),
                    t("Option 2"),
                    t("Option 3"),
                }),
            }),
        })

        ls.config.set_config({ -- Setting LuaSnip config
            -- Enable autotriggered snippets
            enable_autosnippets = true,
        })

        vim.keymap.set({ "i" }, "<C-K>", function()
            ls.expand()
        end, { silent = true })
        vim.keymap.set({ "i", "s" }, "<C-L>", function()
            ls.jump(1)
        end, { silent = true })
        vim.keymap.set({ "i", "s" }, "<C-J>", function()
            ls.jump(-1)
        end, { silent = true })

        vim.keymap.set({ "i", "s" }, "<C-E>", function()
            if ls.choice_active() then
                ls.change_choice(1)
            end
        end, { silent = true })
    end,
}
