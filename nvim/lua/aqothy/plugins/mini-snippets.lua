return {
    "echasnovski/mini.snippets",
    event = "InsertEnter",
    -- enabled = false,
    opts = function()
        local ms = require("mini.snippets")
        local gen_loader = ms.gen_loader

        local my_insert = function(snippet)
            -- Empty tabstop chars
            return ms.default_insert(snippet, { empty_tabstop = "", empty_tabstop_final = "" })
        end

        local autocmd = vim.api.nvim_create_autocmd
        local group = vim.api.nvim_create_augroup("stop_session", { clear = true })

        -- Stop session on esc
        local make_stop = function()
            local au_opts = { pattern = "i*:n", once = true, group = group }
            au_opts.callback = function()
                while ms.session.get() do
                    ms.session.stop()
                end
            end
            autocmd("ModeChanged", au_opts)
        end
        local opts = { pattern = "MiniSnippetsSessionStart", callback = make_stop, group = group }
        autocmd("User", opts)

        local jsx_patterns = { "javascript.json", "react-es7.json" }

        -- :=MiniSnippets.default_prepare({}) to see lang or just press <C-j> in insert mode
        local lang_patterns = {
            jsx = jsx_patterns,
            tsx = jsx_patterns,
            javascript = jsx_patterns,
            typescript = jsx_patterns,
        }

        return {
            snippets = {
                gen_loader.from_file(vim.fn.stdpath("config") .. "/snippets/global.json"),
                gen_loader.from_lang({ lang_patterns = lang_patterns }),
            },
            mappings = {
                expand = "",
                jump_next = "<tab>",
                jump_prev = "<s-tab>",
                stop = "",
            },

            expand = {
                insert = my_insert,
            },
        }
    end,
}
