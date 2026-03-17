local M = {}

function M.pair(next_fn, prev_fn)
    local move

    local function get_move()
        if not move then
            move = require("nvim-treesitter-textobjects.repeatable_move").make_repeatable_move(function(opts, ...)
                if opts.forward then
                    return next_fn(...)
                end

                return prev_fn(...)
            end)
        end

        return move
    end

    return function(...)
        return get_move()({ forward = true }, ...)
    end, function(...)
        return get_move()({ forward = false }, ...)
    end
end

function M.command_pair(next_cmd, prev_cmd)
    return M.pair(function()
        vim.cmd[next_cmd]({ count = vim.v.count1 })
    end, function()
        vim.cmd[prev_cmd]({ count = vim.v.count1 })
    end)
end

return M
