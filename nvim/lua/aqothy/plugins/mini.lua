return {
    -- {
    --     "echasnovski/mini.ai",
    --     event = { "BufReadPre", "BufNewFile" },
        -- opts = function()
        --     local ai = require("mini.ai")
        --     return {
        --         n_lines = 500,
        --         custom_textobjects = {
        --             o = ai.gen_spec.treesitter({ -- code block
        --                 a = { "@block.outer", "@conditional.outer", "@loop.outer" },
        --                 i = { "@block.inner", "@conditional.inner", "@loop.inner" },
        --             }),
        --             f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
        --             c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
        --             t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
        --             d = { "%f[%d]%d+" },                                              -- digits
        --             e = {                                                             -- Word with case
        --                 { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
        --                 "^().*()$",
        --             },
        --         },
        --     }
        -- end,
    --     config = function()
    --         require("mini.ai").setup()
    --     end,
    -- },
    -- {
    --     "echasnovski/mini.surround",
    --     version = false,
    --     event = { "BufReadPre", "BufNewFile" },
    --     opts = {}
    -- },
    -- {
    --     "echasnovski/mini.pairs",
    --     event = "InsertEnter",
    --     opts = {
    --         modes = { insert = true, command = true, terminal = false },
    --         -- skip autopair when next character is one of these
    --         skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
    --         -- skip autopair when the cursor is inside these treesitter nodes
    --         skip_ts = { "string" },
    --         -- skip autopair when next character is closing pair
    --         -- and there are more closing pairs than opening pairs
    --         skip_unbalanced = true,
    --         -- better deal with markdown code blocks
    --         markdown = true,
    --     },
    --     config = function(_, opts)
    --         -- copy pasted straight from lazyvim docs
    --         local pairs = require("mini.pairs")
    --         pairs.setup(opts)
    --         local open = pairs.open
    --         pairs.open = function(pair, neigh_pattern)
    --             if vim.fn.getcmdline() ~= "" then
    --                 return open(pair, neigh_pattern)
    --             end
    --             local o, c = pair:sub(1, 1), pair:sub(2, 2)
    --             local line = vim.api.nvim_get_current_line()
    --             local cursor = vim.api.nvim_win_get_cursor(0)
    --             local next = line:sub(cursor[2] + 1, cursor[2] + 1)
    --             local before = line:sub(1, cursor[2])
    --             if opts.markdown and o == "`" and vim.bo.filetype == "markdown" and before:match("^%s*``") then
    --                 return "`\n```" .. vim.api.nvim_replace_termcodes("<up>", true, true, true)
    --             end
    --             if opts.skip_next and next ~= "" and next:match(opts.skip_next) then
    --                 return o
    --             end
    --             if opts.skip_ts and #opts.skip_ts > 0 then
    --                 local ok, captures = pcall(vim.treesitter.get_captures_at_pos, 0, cursor[1] - 1,
    --                     math.max(cursor[2] - 1, 0))
    --                 for _, capture in ipairs(ok and captures or {}) do
    --                     if vim.tbl_contains(opts.skip_ts, capture.capture) then
    --                         return o
    --                     end
    --                 end
    --             end
    --             if opts.skip_unbalanced and next == c and c ~= o then
    --                 local _, count_open = line:gsub(vim.pesc(pair:sub(1, 1)), "")
    --                 local _, count_close = line:gsub(vim.pesc(pair:sub(2, 2)), "")
    --                 if count_close > count_open then
    --                     return o
    --                 end
    --             end
    --             return open(pair, neigh_pattern)
    --         end
    --     end,
    -- },
    {
        'echasnovski/mini.hipatterns',
        version = false,
        keys = {
            {
                -- Toggle MiniHipatterns state
                "<leader>ct",
                function()
                    if _G.hipatterns_enabled then
                        require('mini.hipatterns').disable()
                        _G.hipatterns_enabled = false
                    else
                        require('mini.hipatterns').enable()
                        _G.hipatterns_enabled = true
                    end
                end,
                desc = "Toggle MiniHipatterns",
            },
        },
        config = function()
            -- Initialize the plugin
            require('mini.hipatterns').setup({
                highlighters = {
                    -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
                    fixme     = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
                    hack      = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
                    todo      = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
                    note      = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },

                    -- Highlight hex color strings (`#rrggbb`) using that color
                    hex_color = require('mini.hipatterns').gen_highlighter.hex_color(),
                },
            })
            -- Set initial state
            _G.hipatterns_enabled = false
        end,
    },
    -- {
    --     "echasnovski/mini.files",
    --     opts = {
    --         options = {
    --             use_as_default_explorer = true,
    --             permanent_delete = false,
    --         },
    --         mappings = {
    --             go_in = 'L',
    --             go_in_plus = '<CR>',
    --             go_out = 'H',
    --             go_out_plus = '-',
    --         },
    --         windows = {
    --             preview = true,
    --             width_preview = 100,
    --         },
    --     },
    --     config = function(_, opts)
    --         -- copy pasted straight from lazyvim docs
    --         require("mini.files").setup(opts)
    --
    --         local show_dotfiles = true
    --
    --         local filter_show = function(_)
    --             return true
    --         end
    --
    --         local filter_hide = function(fs_entry)
    --             return not vim.startswith(fs_entry.name, ".")
    --         end
    --
    --         local toggle_dotfiles = function()
    --             show_dotfiles = not show_dotfiles
    --             local new_filter = show_dotfiles and filter_show or filter_hide
    --             require("mini.files").refresh({ content = { filter = new_filter } })
    --         end
    --
    --         vim.api.nvim_create_autocmd("User", {
    --             pattern = "MiniFilesBufferCreate",
    --             callback = function(args)
    --                 local buf_id = args.data.buf_id
    --
    --                 vim.keymap.set(
    --                     "n",
    --                     "<C-g>",
    --                     toggle_dotfiles,
    --                     { buffer = buf_id, desc = "Toggle hidden files" }
    --                 )
    --
    --                 -- close with <ESC> as well as q
    --                 vim.keymap.set('n', '<ESC>', function()
    --                     require("mini.files").close()
    --                 end, { buffer = buf_id })
    --
    --                 vim.api.nvim_set_option_value('buftype', 'acwrite', { buf = buf_id })
    --                 vim.api.nvim_buf_set_name(buf_id, string.format('mini.files-%s', vim.loop.hrtime()))
    --                 vim.api.nvim_create_autocmd('BufWriteCmd', {
    --                     buffer = buf_id,
    --                     callback = function()
    --                         require("mini.files").synchronize()
    --                     end,
    --                 })
    --             end,
    --         })
    --
    --         vim.api.nvim_create_autocmd("User", {
    --             pattern = "MiniFilesActionRename",
    --             callback = function(event)
    --                 Snacks.rename.on_rename_file(event.data.from, event.data.to)
    --             end,
    --         })
    --
    --         vim.keymap.set("n", "-", function()
    --             require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
    --         end, { desc = "Open mini.files (Directory of Current File)" })
    --
    --         vim.keymap.set("n", "<leader>ee", function()
    --             require("mini.files").open(vim.uv.cwd(), true)
    --         end, { desc = "Open mini.files (cwd, hide dotfiles by default)" })
    --     end,
    -- }
}
