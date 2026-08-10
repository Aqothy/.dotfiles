-- Minimal vim.pack wrapper for the Lazy-style fields used in this config.
-- It is intentionally not a full lazy.nvim compatibility layer.
local M = {}

local lazy_file_events = { "BufReadPre", "BufNewFile", "BufWritePre" }

M.events = {
    LazyFile = { id = "LazyFile", event = lazy_file_events },
}

local specs = {}
local loaded = {}

local function list(value)
    if value == nil then
        return {}
    end
    return type(value) == "table" and value or { value }
end

local function name_from_src(src)
    return src:gsub("%.git$", ""):match("([^/:%s]+)$") or src
end

local function pack_spec(spec)
    local src = spec[1]
    if not (src:match("^https?://") or src:match("^ssh://") or src:match("^git@") or src:match("^[%w+.-]+:")) then
        src = "https://github.com/" .. src
    end

    local version = spec.version ~= false and spec.version or nil
    if version == "*" then
        version = vim.version.range("*")
    end

    return { src = src, name = spec.name, version = version }
end

local function keys(spec)
    if spec._keys == nil then
        if type(spec.keys) == "function" then
            local value = spec.keys(spec)
            spec._keys = value == nil and false or value
        else
            spec._keys = spec.keys or false
        end
    end
    return spec._keys ~= false and spec._keys or nil
end

local function key_parts(key)
    key = type(key) == "string" and { key } or key

    local mode, lhs, rhs = key.mode or "n", key[1], key[2]

    local opts = {}
    for k, v in pairs(key) do
        if type(k) == "string" and k ~= "mode" then
            opts[k] = v
        end
    end

    return mode, lhs, rhs, opts
end

local function set_keymap(mode, lhs, rhs, opts)
    if rhs then
        local map_opts = vim.deepcopy(opts)
        vim.keymap.set(mode, lhs, rhs, map_opts)
    end
end

local function del_keymap(mode, lhs)
    pcall(vim.keymap.del, mode, lhs)
end

local function apply_keys(spec)
    for _, key in ipairs(list(keys(spec))) do
        local mode, lhs, rhs, opts = key_parts(key)

        if rhs then
            set_keymap(mode, lhs, rhs, opts)
        end
    end
end

local function load_plugin(spec)
    if not spec or loaded[spec.name] then
        return
    end
    loaded[spec.name] = true

    for _, dep in ipairs(list(spec.dependencies)) do
        local name = specs[dep] and dep or name_from_src(dep)
        if specs[name] then
            load_plugin(specs[name])
        else
            vim.notify(("Missing pack dependency '%s' for %s"):format(dep, spec.name), vim.log.levels.WARN)
        end
    end

    for _, cmd in ipairs(list(spec.cmd)) do
        pcall(vim.api.nvim_del_user_command, cmd)
    end
    for _, key in ipairs(list(keys(spec))) do
        local mode, lhs = key_parts(key)
        for _, m in ipairs(list(mode)) do
            del_keymap(m, lhs)
        end
    end

    vim.cmd.packadd(spec.name)

    local opts = spec.opts
    if type(opts) == "function" then
        local base = {}
        opts = opts(spec, base) or base
    elseif type(opts) == "table" then
        opts = vim.deepcopy(opts)
    end

    if spec.config then
        spec.config(spec, opts)
    elseif opts ~= nil then
        local mod_name = spec.mod_name or spec.name:gsub("%.nvim$", "")
        local ok, mod = pcall(require, mod_name)
        if not ok then
            error(("Failed to require '%s' for %s: %s"):format(mod_name, spec.name, mod))
        end
        mod.setup(opts)
    end

    if keys(spec) then
        apply_keys(spec)
    end
end

local function run_build(spec)
    if type(spec.build) == "function" then
        load_plugin(spec)
        spec.build()
    end
end

function M.setup(opts)
    opts = opts or {}
    specs, loaded = {}, {}

    local config_lua = vim.fn.stdpath("config") .. "/lua"
    local order, to_add, startup, very_lazy, event_queue, build_queue = {}, {}, {}, {}, {}, {}
    local installing = false

    local function add_spec(spec)
        if type(spec) ~= "table" or type(spec[1]) ~= "string" then
            return
        end

        spec = vim.deepcopy(spec)
        spec.name = spec.name or name_from_src(spec[1])
        if spec.enabled == false then
            return
        end
        if type(spec.enabled) == "function" and not spec.enabled(spec) then
            return
        end
        if opts.cond == false then
            return
        end
        if type(opts.cond) == "function" and not opts.cond(spec) then
            return
        end

        local existing = specs[spec.name]
        if existing then
            for k, v in pairs(spec) do
                if k == "opts" and type(existing.opts) == "table" and type(v) == "table" then
                    existing.opts = vim.tbl_deep_extend("force", existing.opts, v)
                elseif k ~= 1 then
                    existing[k] = v
                end
            end
        else
            specs[spec.name] = spec
            table.insert(order, spec)
        end
    end

    local function add_specs(value)
        if type(value) == "table" and type(value[1]) == "string" then
            add_spec(value)
            return
        end
        for _, spec in ipairs(value or {}) do
            add_spec(spec)
        end
    end

    local function queue_event(id, event, pattern, spec)
        event_queue[id] = event_queue[id] or { event = event, pattern = pattern, specs = {} }
        table.insert(event_queue[id].specs, spec)
    end

    for _, import in ipairs(opts.imports or { "plugins" }) do
        local rel = import:gsub("%.", "/")
        local file = config_lua .. "/" .. rel .. ".lua"
        local dir = config_lua .. "/" .. rel

        if vim.uv.fs_stat(file) then
            add_specs(require(import))
        elseif vim.uv.fs_stat(dir) then
            local entries = {}
            for name, kind in vim.fs.dir(dir) do
                table.insert(entries, { name = name, kind = kind })
            end
            table.sort(entries, function(a, b)
                return a.name < b.name
            end)

            for _, entry in ipairs(entries) do
                if entry.kind == "file" and entry.name:match("%.lua$") and entry.name ~= "init.lua" then
                    add_specs(require(import .. "." .. entry.name:gsub("%.lua$", "")))
                elseif entry.kind == "directory" and vim.uv.fs_stat(dir .. "/" .. entry.name .. "/init.lua") then
                    add_specs(require(import .. "." .. entry.name))
                end
            end
        end
    end

    vim.api.nvim_create_autocmd("PackChanged", {
        group = vim.api.nvim_create_augroup("custom/pack-build", { clear = true }),
        callback = function(ev)
            if ev.data.kind ~= "install" and ev.data.kind ~= "update" then
                return
            end
            local spec = specs[ev.data.spec.name]
            if spec and spec.build then
                if installing then
                    table.insert(build_queue, spec)
                else
                    run_build(spec)
                end
            end
        end,
    })

    for _, spec in ipairs(order) do
        table.insert(to_add, pack_spec(spec))
        if spec.init then
            spec.init()
        end

        local spec_keys = keys(spec)
        local lazy = spec.lazy
        if lazy == nil then
            lazy = spec_keys or spec.cmd or spec.event or spec.ft
        end

        if not lazy then
            table.insert(startup, spec)
        else
            for _, event in ipairs(list(spec.event)) do
                if event == "VeryLazy" then
                    table.insert(very_lazy, spec)
                else
                    local alias = M.events[event]
                    if alias then
                        queue_event(alias.id, alias.event, alias.pattern, spec)
                    else
                        queue_event(event, event, nil, spec)
                    end
                end
            end

            for _, ft in ipairs(list(spec.ft)) do
                queue_event("FileType " .. ft, "FileType", ft, spec)
            end

            for _, key in ipairs(list(spec_keys)) do
                local mode, lhs, _, key_opts = key_parts(key)
                for _, m in ipairs(list(mode)) do
                    local function set_stub()
                        vim.keymap.set(m, lhs, function()
                            load_plugin(spec)

                            local feed = lhs
                            if m:sub(-1) == "a" then
                                feed = feed .. "<C-]>"
                            end
                            feed = vim.api.nvim_replace_termcodes("<Ignore>" .. feed, true, true, true)
                            vim.api.nvim_feedkeys(feed, "i", false)
                        end, {
                            desc = key_opts.desc,
                            nowait = key_opts.nowait,
                            expr = true,
                        })
                    end

                    set_stub()
                end
            end

            for _, cmd in ipairs(list(spec.cmd)) do
                vim.api.nvim_create_user_command(cmd, function(ev)
                    local command = {
                        cmd = cmd,
                        bang = ev.bang or nil,
                        mods = ev.smods,
                        args = ev.fargs,
                        count = ev.count >= 0 and ev.range == 0 and ev.count or nil,
                    }
                    if ev.range == 1 then
                        command.range = { ev.line1 }
                    elseif ev.range == 2 then
                        command.range = { ev.line1, ev.line2 }
                    end

                    load_plugin(spec)

                    local info = vim.api.nvim_get_commands({})[cmd] or vim.api.nvim_buf_get_commands(0, {})[cmd]
                    if not info then
                        vim.notify("Command not found after loading: " .. cmd, vim.log.levels.ERROR)
                        return
                    end
                    command.nargs = info.nargs
                    if ev.args and ev.args ~= "" and info.nargs and info.nargs:find("[1?]") then
                        command.args = { ev.args }
                    end
                    vim.cmd(command)
                end, {
                    bang = true,
                    nargs = "*",
                    range = true,
                    complete = function(_, line)
                        load_plugin(spec)
                        return vim.fn.getcompletion(line, "cmdline")
                    end,
                })
            end
        end
    end

    local event_group = vim.api.nvim_create_augroup("custom/pack-events", { clear = true })
    for id, queued in pairs(event_queue) do
        vim.api.nvim_create_autocmd(queued.event, {
            group = event_group,
            pattern = queued.pattern,
            once = true,
            nested = true,
            desc = "Pack lazy " .. id,
            callback = function()
                for _, spec in ipairs(queued.specs) do
                    load_plugin(spec)
                end
            end,
        })
    end

    if #to_add > 0 then
        installing = true
        vim.pack.add(to_add, { confirm = false, load = function() end })
        installing = false
    end

    for _, spec in ipairs(build_queue) do
        run_build(spec)
    end

    table.sort(startup, function(a, b)
        return (a.priority or 0) > (b.priority or 0)
    end)
    for _, spec in ipairs(startup) do
        load_plugin(spec)
    end

    local function fire_very_lazy()
        vim.schedule(function()
            if vim.v.exiting ~= vim.NIL then
                return
            end

            for _, spec in ipairs(very_lazy) do
                load_plugin(spec)
            end
        end)
    end

    if vim.v.vim_did_enter == 1 then
        fire_very_lazy()
    else
        vim.api.nvim_create_autocmd("UIEnter", {
            group = vim.api.nvim_create_augroup("custom/pack-very-lazy", { clear = true }),
            once = true,
            nested = true,
            callback = fire_very_lazy,
        })
    end
end

function M.load(names)
    for _, name in ipairs(list(names)) do
        local spec = specs[specs[name] and name or name_from_src(name)]
        if spec then
            load_plugin(spec)
        else
            vim.notify("Unknown pack plugin: " .. name, vim.log.levels.WARN)
        end
    end
end

return M
