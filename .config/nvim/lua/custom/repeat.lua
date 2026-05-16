local M = {}
local state = { f = nil, b = nil }

M.config = {
    strict_direction = false,
}

function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

local function fallback(key)
    local count = vim.v.count > 0 and vim.v.count or ""
    return count .. key
end

function M._repeat(dir)
    local f = state[dir]
    if f then
        f()
    end
end

function M.semicolon()
    if state.f then
        return "<Cmd>lua require('custom.repeat')._repeat('f')<CR>"
    end
    return fallback(";")
end

function M.comma()
    if state.b then
        return "<Cmd>lua require('custom.repeat')._repeat('b')<CR>"
    end
    return fallback(",")
end

function M.pair(fwd, bwd)
    local function wrap(f, is_fwd)
        return function(...)
            local args = { ... }
            local a = function()
                fwd(unpack(args))
            end
            local b = function()
                bwd(unpack(args))
            end

            if M.config.strict_direction or is_fwd then
                state.f, state.b = a, b
            else
                state.f, state.b = b, a
            end
            return f(unpack(args))
        end
    end
    return wrap(fwd, true), wrap(bwd, false)
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
