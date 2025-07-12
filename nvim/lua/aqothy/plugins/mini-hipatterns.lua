return {
    "echasnovski/mini.hipatterns",
    event = "LazyFile",
    keys = {
        {
            "<leader>th",
            function()
                MiniHipatterns.toggle()
            end,
            desc = "Toggle MiniHipatterns",
        },
    },
    opts = function()
        local hi = require("mini.hipatterns")
        return {
            highlighters = {
                fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
                hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
                todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
                note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
                dotenv = {
                    pattern = function(buf_id)
                        if vim.bo[buf_id].filetype ~= "dotenv" then
                            return nil
                        end
                        return "=()%S+()"
                    end,
                    group = "",
                    extmark_opts = function(_, match, _)
                        local mask = string.rep("*", vim.fn.strchars(match))
                        return {
                            virt_text = { { mask, "Comment" } },
                            virt_text_pos = "overlay",
                            priority = 200,
                            right_gravity = false,
                        }
                    end,
                },

                hex_color = hi.gen_highlighter.hex_color({ priority = 2000 }),
            },
        }
    end,
}
