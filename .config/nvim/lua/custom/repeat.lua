local M = {}
local state = { f = nil, b = nil }

M.config = {
    strict_direction = false,
}

function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

local function run(key)
    local count = vim.v.count > 0 and vim.v.count or ""
    vim.api.nvim_feedkeys(vim.keycode(count .. key), "n", false)
end

function M.semicolon()
    if state.f then
        state.f()
    else
        run(";")
    end
end

function M.comma()
    if state.b then
        state.b()
    else
        run(",")
    end
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
