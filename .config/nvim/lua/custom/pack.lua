-- Minimal vim.pack wrapper for the Lazy-style fields used in this config.
-- It is intentionally not a full lazy.nvim compatibility layer.
local M = {}

local lazy_file_events = { "BufReadPost", "BufNewFile", "BufWritePre" }

M.events = {
    VeryLazy = { id = "VeryLazy", event = "User", pattern = "VeryLazy" },
    LazyFile = { id = "LazyFile", event = lazy_file_events },
}
M.events["User VeryLazy"] = M.events.VeryLazy
M.events["User LazyFile"] = M.events.LazyFile

M.event_triggers = { FileType = "BufReadPost", BufReadPost = "BufReadPre" }

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
        spec._keys = type(spec.keys) == "function" and spec.keys(spec) or spec.keys or false
    end
    return spec._keys ~= false and spec._keys or nil
end

local function key_parts(key)
    key = type(key) == "string" and { key } or key

    local mode, lhs, rhs
    if key[3] ~= nil then
        mode, lhs, rhs = key[1], key[2], key[3]
    else
        mode, lhs, rhs = key.mode or "n", key[1], key[2]
    end

    local opts = {}
    for k, v in pairs(key) do
        if type(k) == "string" and k ~= "mode" and k ~= "ft" and k ~= "enabled" and k ~= "cond" then
            opts[k] = v
        end
    end

    return mode, lhs, rhs, opts
end

local function apply_keys(spec, buf)
    for _, key in ipairs(list(keys(spec))) do
        local mode, lhs, rhs, opts = key_parts(key)
        local bufs = { false }

        if key.ft then
            bufs = {}
            for _, b in ipairs(buf and { buf } or vim.api.nvim_list_bufs()) do
                if vim.tbl_contains(list(key.ft), vim.bo[b].filetype) then
                    table.insert(bufs, b)
                end
            end
        end

        for _, b in ipairs(bufs) do
            local map_opts = vim.deepcopy(opts)
            map_opts.buffer = b or nil
            if rhs ~= nil and rhs ~= false then
                vim.keymap.set(mode, lhs, rhs, map_opts)
            else
                pcall(vim.keymap.del, mode, lhs, { buffer = b or nil })
            end
        end
    end
end

local load_plugin
load_plugin = function(spec, defer)
    if not spec or loaded[spec.name] then
        return
    end
    loaded[spec.name] = true

    for _, dep in ipairs(list(spec.dependencies)) do
        local dep_name = specs[dep] and dep or name_from_src(dep)
        if specs[dep_name] then
            load_plugin(specs[dep_name], defer)
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
            if key.ft then
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.tbl_contains(list(key.ft), vim.bo[buf].filetype) then
                        pcall(vim.keymap.del, m, lhs, { buffer = buf })
                    end
                end
            else
                pcall(vim.keymap.del, m, lhs)
            end
        end
    end

    vim.cmd.packadd({ spec.name, bang = defer })

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

    if spec.keys then
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
    local order, to_add, startup, event_queue, build_queue = {}, {}, {}, {}, {}
    local installing = false

    local function add_spec(spec)
        if type(spec) ~= "table" or type(spec[1]) ~= "string" then
            return
        end

        spec.name = spec.name or name_from_src(spec[1])
        if spec.enabled == false then
            return
        end
        if type(spec.enabled) == "function" and not spec.enabled(spec) then
            return
        end
        if spec.cond == false then
            return
        end
        if type(spec.cond) == "function" and not spec.cond(spec) then
            return
        end
        if opts.cond and not opts.cond(spec) then
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

    local function queue_event(event, spec)
        if type(event) ~= "string" then
            return
        end

        local parsed = M.events[event]
        if parsed then
            parsed = type(parsed) == "table" and vim.deepcopy(parsed) or { event = parsed }
            if parsed.event == nil and parsed[1] ~= nil then
                parsed = { event = parsed }
            end
            parsed.id = parsed.id or event
            parsed.event = parsed.event or event
        else
            local event_name, pattern = event:match("^(%w+)%s+(.+)$")
            parsed = { id = event, event = event_name or event, pattern = pattern }
        end

        event_queue[parsed.id] = event_queue[parsed.id]
            or { event = parsed.event, pattern = parsed.pattern, specs = {} }
        table.insert(event_queue[parsed.id].specs, spec)
    end

    for _, import in ipairs(opts.imports or { "plugins" }) do
        local rel = import:gsub("%.", "/")
        local file = config_lua .. "/" .. rel .. ".lua"
        local dir = config_lua .. "/" .. rel

        if vim.uv.fs_stat(file) then
            add_specs(require(import))
        else
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

        local lazy = spec.lazy
        if lazy == nil then
            lazy = spec.keys or spec.cmd or spec.event or spec.ft
        end

        if not lazy then
            if spec.keys then
                apply_keys(spec)
            end
            table.insert(startup, spec)
        else
            for _, event in ipairs(list(spec.event)) do
                queue_event(event, spec)
            end

            for _, ft in ipairs(list(spec.ft)) do
                local id = "FileType " .. ft
                event_queue[id] = event_queue[id] or { event = "FileType", pattern = ft, specs = {} }
                table.insert(event_queue[id].specs, spec)
            end

            for _, key in ipairs(list(keys(spec))) do
                local mode, lhs, _, key_opts = key_parts(key)
                local function set_stub(buf)
                    for _, m in ipairs(list(mode)) do
                        vim.keymap.set(m, lhs, function()
                            apply_keys(spec, buf)
                            load_plugin(spec)

                            local feed = lhs
                            if m:sub(-1) == "a" then
                                feed = feed .. "<C-]>"
                            end
                            feed = vim.api.nvim_replace_termcodes("<Ignore>" .. feed, true, true, true)
                            vim.api.nvim_feedkeys(feed, "i", false)
                        end, {
                            buffer = buf,
                            desc = key_opts.desc,
                            nowait = key_opts.nowait,
                            expr = true,
                        })
                    end
                end

                if key.ft then
                    vim.api.nvim_create_autocmd("FileType", {
                        pattern = key.ft,
                        nested = true,
                        callback = function(ev)
                            if loaded[spec.name] then
                                apply_keys(spec, ev.buf)
                            else
                                set_stub(ev.buf)
                            end
                        end,
                    })
                else
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

                    for _, c in ipairs(list(spec.cmd)) do
                        pcall(vim.api.nvim_del_user_command, c)
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
                        for _, c in ipairs(list(spec.cmd)) do
                            pcall(vim.api.nvim_del_user_command, c)
                        end
                        load_plugin(spec)
                        return vim.fn.getcompletion(line, "cmdline")
                    end,
                })
            end
        end
    end

    -- Event replay is the biggest unavoidable chunk. This mirrors lazy.nvim's
    -- event handler: snapshot existing groups, load plugins, then fire only the
    -- newly-created handlers so plugins do not miss the event that loaded them.
    local event_group = vim.api.nvim_create_augroup("custom/pack-events", { clear = true })
    for id, queued in pairs(event_queue) do
        vim.api.nvim_create_autocmd(queued.event, {
            group = event_group,
            pattern = queued.pattern,
            once = true,
            nested = true,
            desc = "Pack lazy " .. id,
            callback = function(ev)
                local chain = {}
                local current, data = ev.event, ev.data

                while current do
                    local exclude = {}
                    if current ~= "FileType" then
                        for _, autocmd in ipairs(vim.api.nvim_get_autocmds({ event = current })) do
                            if autocmd.group_name then
                                exclude[autocmd.group_name] = true
                            end
                        end
                    end
                    table.insert(chain, 1, { event = current, buffer = ev.buf, data = data, exclude = exclude })
                    current, data = M.event_triggers[current], nil
                end

                for _, spec in ipairs(queued.specs) do
                    load_plugin(spec)
                end

                for _, item in ipairs(chain) do
                    if next(item.exclude) == nil then
                        vim.api.nvim_exec_autocmds(item.event, {
                            buffer = item.buffer,
                            modeline = false,
                            data = item.data,
                        })
                    else
                        local done = {}
                        for _, autocmd in ipairs(vim.api.nvim_get_autocmds({ event = item.event })) do
                            local autocmd_id = autocmd.event .. ":" .. (autocmd.group or "")
                            local skip = done[autocmd_id] or item.exclude[autocmd.group_name]
                            done[autocmd_id] = true
                            if autocmd.group and not skip then
                                vim.api.nvim_exec_autocmds(item.event, {
                                    buffer = item.buffer,
                                    group = autocmd.group_name,
                                    modeline = false,
                                    data = item.data,
                                })
                            end
                        end
                    end
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
        load_plugin(spec, true)
    end

    local function fire_very_lazy()
        vim.schedule(function()
            if vim.v.exiting ~= vim.NIL then
                return
            end
            vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy", modeline = false })
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

function M.is_loaded(name)
    return loaded[specs[name] and name or name_from_src(name)] == true
end

return M
