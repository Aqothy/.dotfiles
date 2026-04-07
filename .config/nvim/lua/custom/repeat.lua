local M = {}
local state = { f = nil, b = nil }

local function run(key)
    local count = vim.v.count > 0 and vim.v.count or ""
    vim.api.nvim_feedkeys(vim.keycode(count .. key), "n", false)
end

local function repeat_or_run(direction, fallback)
    local fn = state[direction]
    if fn then
        fn()
    else
        run(fallback)
    end
end

function M.semicolon()
    repeat_or_run("f", ";")
end

function M.comma()
    repeat_or_run("b", ",")
end

function M.pair(fwd, bwd)
    local function wrap(f, reverse)
        return function(...)
            local args = { ... }
            state.f = function()
                fwd(unpack(args))
            end
            state.b = function()
                reverse(unpack(args))
            end
            return f(unpack(args))
        end
    end
    return wrap(fwd, bwd), wrap(bwd, fwd)
end

function M.command_pair(next_cmd, prev_cmd)
    return M.pair(function()
        vim.cmd[next_cmd]({ count = vim.v.count1 })
    end, function()
        vim.cmd[prev_cmd]({ count = vim.v.count1 })
    end)
end

local function builtin(key)
    return function()
        state.f, state.b = nil, nil
        return key
    end
end

M.builtin_f_expr, M.builtin_F_expr = builtin("f"), builtin("F")
M.builtin_t_expr, M.builtin_T_expr = builtin("t"), builtin("T")

return M
