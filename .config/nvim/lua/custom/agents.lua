local M = {}

local defaults = {
    agents = {
        pi = { cmd = { "pi" } },
        codex = { cmd = { "codex", "--yolo" } },
        claude = { cmd = { "claude", "--dangerously-skip-permissions" } },
    },
    width = 0.4,
    keys = {
        select = { "<a-.>", "select", mode = { "n", "t" }, desc = "Agent Select" },
        toggle = { "<c-.>", "toggle", mode = { "n", "t" }, desc = "Agent toggle" },
        next = { "<a-n>", "next", mode = { "n", "t" }, desc = "Agent Next" },
        left = { "<c-h>", "left", mode = { "n", "t" }, desc = "Go Left" },
    },
}

local config = vim.deepcopy(defaults)
local state = { tabs = {} }
local severity = vim.diagnostic.severity
local severity_name = {
    [severity.ERROR] = "ERROR",
    [severity.WARN] = "WARN",
    [severity.INFO] = "INFO",
    [severity.HINT] = "HINT",
}

local instance_counter = 0
local function make_id(name)
    instance_counter = instance_counter + 1
    return name .. "-" .. instance_counter
end

local function tab_state()
    local id = vim.api.nvim_get_current_tabpage()
    state.tabs[id] = state.tabs[id] or { current = nil, agents = {} }
    return state.tabs[id]
end

local function notify(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO, { title = "Agent" })
end

local function visible(entry)
    return entry and entry.win and vim.api.nvim_win_is_valid(entry.win)
end

local function cleanup_entry(entry)
    if entry.win and vim.api.nvim_win_is_valid(entry.win) then
        pcall(vim.api.nvim_win_close, entry.win, true)
    end
    if entry.buf and vim.api.nvim_buf_is_valid(entry.buf) then
        pcall(vim.api.nvim_buf_delete, entry.buf, { force = true })
    end
end

local function finish_entry(tab, id, entry)
    cleanup_entry(entry)
    tab.agents[id] = nil
    if tab.current == id then
        tab.current = nil
    end
end

local function stop_entry(tab, id, entry)
    pcall(vim.fn.jobstop, entry.job)
    finish_entry(tab, id, entry)
end

local function stop_tab(id, tab)
    for agent_id, entry in pairs(tab.agents) do
        stop_entry(tab, agent_id, entry)
    end
    state.tabs[id] = nil
end

local function cleanup_closed_tabs()
    for id, tab in pairs(state.tabs) do
        if not vim.api.nvim_tabpage_is_valid(id) then
            stop_tab(id, tab)
        end
    end
end

local function stop_all()
    for id, tab in pairs(state.tabs) do
        stop_tab(id, tab)
    end
end

local function running_agents(tab)
    local ids = {}
    for id in pairs(tab.agents) do
        ids[#ids + 1] = id
    end
    table.sort(ids, function(a, b)
        local ea, eb = tab.agents[a], tab.agents[b]
        if ea.name ~= eb.name then
            return ea.name < eb.name
        end
        return a < b
    end)
    return ids
end

local function hide(tab)
    local entry = tab.current and tab.agents[tab.current]
    if entry then
        if entry.win and vim.api.nvim_win_is_valid(entry.win) then
            pcall(vim.api.nvim_win_close, entry.win, true)
        end
        entry.win = nil
    end
    tab.current = nil
end

local function format_ref(name)
    return "@" .. (name ~= "" and name or "[No Name]")
end

local function file_ref(buf)
    local name = vim.api.nvim_buf_get_name(buf or 0)
    name = name ~= "" and vim.fn.fnamemodify(name, ":.") or ""
    return format_ref(name)
end

local function line_ref(first, last)
    return last and last ~= first and (":L%d-L%d"):format(first, last) or (":L%d"):format(first)
end

local function open_right(buf)
    local width = config.width <= 1 and math.floor(vim.o.columns * config.width) or config.width
    if buf then
        vim.cmd("botright vertical sbuffer " .. buf)
    else
        vim.cmd("botright vertical " .. width .. "new")
    end
    vim.cmd("vertical resize " .. width)
    local win = vim.api.nvim_get_current_win()
    vim.wo[win].scrolloff = vim.go.scrolloff
    vim.wo[win].sidescrolloff = vim.go.sidescrolloff
    return win
end

local function restore_mode(entry)
    if entry.mode == "n" then
        vim.cmd.stopinsert()
    else
        vim.cmd.startinsert()
    end
end

local function open_win(tab, id, entry)
    local reuse_win
    if tab.current ~= id then
        local current = tab.current and tab.agents[tab.current]
        if current and current.win and vim.api.nvim_win_is_valid(current.win) then
            reuse_win = current.win
            current.win = nil
        end
    end

    if visible(entry) then
        vim.api.nvim_set_current_win(entry.win)
    elseif reuse_win and vim.api.nvim_win_is_valid(reuse_win) then
        vim.api.nvim_set_current_win(reuse_win)
        vim.api.nvim_win_set_buf(reuse_win, entry.buf)
        entry.win = reuse_win
    else
        entry.win = open_right(entry.buf)
    end
    tab.current = id
    restore_mode(entry)
end

local function set_terminal_keys(buf)
    local actions = {
        toggle = M.toggle,
        select = M.select,
        next = M.next,
        left = function()
            vim.cmd.wincmd("h")
        end,
    }
    for _, key in pairs(config.keys or {}) do
        local rhs = type(key[2]) == "string" and actions[key[2]] or key[2]
        if rhs then
            vim.keymap.set(key.mode or { "n", "t" }, key[1], rhs, { buf = buf, silent = true, desc = key.desc })
        end
    end
end

---@param name string
---@return { job_cmd: string[], cmd_display: string, executable: string? }?
local function agent_cmd(name)
    local spec = config.agents[name]
    local cmd = spec and spec.cmd
    if type(cmd) == "string" and vim.trim(cmd) ~= "" then
        return {
            job_cmd = { vim.o.shell, vim.o.shellcmdflag, cmd },
            cmd_display = cmd,
        }
    end
    if type(cmd) == "table" and cmd[1] then
        return {
            job_cmd = cmd,
            cmd_display = table.concat(cmd, " "),
            executable = cmd[1],
        }
    end
    notify("Invalid agent config: " .. name, vim.log.levels.ERROR)
end

local function start_agent(tab, name)
    local cmd = agent_cmd(name)
    if not cmd then
        return
    end
    if cmd.executable and vim.fn.executable(cmd.executable) ~= 1 then
        notify("Executable not found: " .. cmd.executable, vim.log.levels.ERROR)
        return
    end

    hide(tab)
    local win = open_right()
    local buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].buflisted = false

    local id = make_id(name)
    local entry = { buf = buf, win = win, job = nil, mode = "t", name = name }
    set_terminal_keys(buf)
    vim.api.nvim_create_autocmd({ "TermLeave", "TermEnter" }, {
        buf = buf,
        callback = function()
            vim.schedule(function()
                if vim.api.nvim_get_current_buf() == buf then
                    entry.mode = vim.fn.mode() == "t" and "t" or "n"
                end
            end)
        end,
    })
    vim.api.nvim_create_autocmd("WinEnter", {
        buf = buf,
        callback = function()
            restore_mode(entry)
        end,
    })
    tab.agents[id] = entry
    tab.current = id

    entry.job = vim.fn.jobstart(cmd.job_cmd, {
        cwd = vim.uv.cwd(),
        term = true,
        on_exit = function(_, code)
            vim.schedule(function()
                if tab.agents[id] == entry then
                    finish_entry(tab, id, entry)
                end
                if code ~= 0 then
                    notify(name .. " exited with code " .. code, vim.log.levels.WARN)
                end
            end)
        end,
    })

    if entry.job <= 0 then
        notify("Failed to run " .. cmd.cmd_display, vim.log.levels.ERROR)
        hide(tab)
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
        tab.agents[id] = nil
        return
    end

    restore_mode(entry)
    return entry
end

local function use_agent(id)
    local tab = tab_state()
    local entry = tab.agents[id]
    if not entry then
        notify("Agent not found: " .. tostring(id), vim.log.levels.WARN)
        return
    end
    open_win(tab, id, entry)
    return entry
end

local function pick_agent(cb, prefer_running)
    local tab = tab_state()
    local running_ids = running_agents(tab)
    local items = {}
    local active_id = tab.current

    local name_counts = {}
    for _, id in ipairs(running_ids) do
        local n = tab.agents[id].name
        name_counts[n] = (name_counts[n] or 0) + 1
    end

    if active_id and vim.tbl_contains(running_ids, active_id) then
        local entry = tab.agents[active_id]
        local label = entry.name
        if name_counts[entry.name] > 1 then
            label = label .. " (" .. active_id .. ")"
        end
        items[#items + 1] = {
            type = "instance",
            id = active_id,
            display = label .. "  ● active",
        }
    end

    for _, id in ipairs(running_ids) do
        if id ~= active_id then
            local entry = tab.agents[id]
            local label = entry.name
            if name_counts[entry.name] > 1 then
                label = label .. " (" .. id .. ")"
            end
            items[#items + 1] = {
                type = "instance",
                id = id,
                display = label .. "  ● running",
            }
        end
    end

    local configured = vim.tbl_keys(config.agents)
    table.sort(configured)

    if not prefer_running or #items == 0 then
        for _, name in ipairs(configured) do
            items[#items + 1] = {
                type = "new",
                name = name,
                display = name .. " (new)",
            }
        end
    end

    if #items == 0 then
        return notify("No agents configured", vim.log.levels.WARN)
    end

    if #items == 1 then
        local item = items[1]
        local entry
        if item.type == "new" then
            entry = start_agent(tab, item.name)
        else
            entry = use_agent(item.id)
        end
        if entry and cb then
            cb(entry)
        end
        return
    end

    vim.ui.select(items, {
        prompt = "Select agent",
        format_item = function(item)
            return item.display
        end,
    }, function(item)
        if not item then
            return
        end
        local entry
        if item.type == "new" then
            entry = start_agent(tab, item.name)
        else
            entry = use_agent(item.id)
        end
        if entry and cb then
            cb(entry)
        end
    end)
end

local function with_agent(cb)
    local tab = tab_state()
    local entry = tab.current and tab.agents[tab.current]
    if not entry then
        return pick_agent(cb, true)
    end
    open_win(tab, tab.current, entry)
    cb(entry)
end

local function paste(entry, text)
    text = text:gsub("\r\n", "\n")
    if text:sub(-1) ~= "\n" then
        text = text .. "\n"
    end
    -- Send as bracketed paste so tabs/newlines are inserted literally.
    vim.api.nvim_chan_send(entry.job, "\27[200~" .. text .. "\27[201~")
    vim.api.nvim_set_current_win(entry.win)
    vim.cmd.startinsert()
end

local function send_text(text)
    with_agent(function(entry)
        paste(entry, text)
    end)
end

local function send_block(buf, first, last, text)
    send_text(file_ref(buf) .. " " .. line_ref(first, last) .. "\n" .. text)
end

local function get_selection()
    local mode = vim.fn.mode()
    local visual = mode == "v" or mode == "V" or mode == "\22"
    local kind = visual and mode or vim.fn.visualmode()
    if kind == "" then
        kind = "v"
    end

    if visual then
        vim.cmd("normal! " .. mode)
    end

    local from = vim.fn.getpos("'<")
    local to = vim.fn.getpos("'>")
    local first, last = from[2], to[2]
    if first > last then
        first, last = last, first
    end

    local text = table.concat(
        vim.fn.getregion(from, to, {
            type = kind,
            exclusive = vim.o.selection == "exclusive",
        }),
        "\n"
    )

    return first, last, text
end

local function diag_line(diagnostic)
    local msg = vim.trim((diagnostic.message or ""):gsub("%s+", " "))
    local parts = {
        ("[%s] %s"):format(severity_name[diagnostic.severity] or "INFO", msg),
    }
    if diagnostic.source and diagnostic.source ~= "" then
        parts[#parts + 1] = diagnostic.source
    end
    if diagnostic.code and diagnostic.code ~= "" then
        parts[#parts + 1] = tostring(diagnostic.code)
    end
    return table.concat(parts, " ") .. " " .. file_ref(diagnostic.bufnr) .. " " .. line_ref(diagnostic.lnum + 1)
end

local function open_diagnostics()
    local items = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
            vim.list_extend(items, vim.diagnostic.get(buf))
        end
    end
    table.sort(items, function(a, b)
        if a.bufnr == b.bufnr then
            return a.lnum < b.lnum
        end
        return file_ref(a.bufnr) < file_ref(b.bufnr)
    end)
    return items
end

local function send_diagnostics(items)
    if #items == 0 then
        return notify("No diagnostics")
    end
    local lines = {}
    for _, diagnostic in ipairs(items) do
        lines[#lines + 1] = diag_line(diagnostic)
    end
    send_text(table.concat(lines, "\n"))
end

function M.toggle()
    local tab = tab_state()
    local entry = tab.current and tab.agents[tab.current]
    if visible(entry) then
        return hide(tab)
    end
    tab.current = nil
    pick_agent(nil, true)
end

function M.select()
    pick_agent()
end

function M.next()
    local tab = tab_state()
    local ids = running_agents(tab)

    if #ids == 0 then
        return pick_agent()
    end
    if #ids == 1 then
        return use_agent(ids[1])
    end

    if not tab.current then
        return pick_agent(nil, true)
    end
    for i, id in ipairs(ids) do
        if id == tab.current then
            return use_agent(ids[i % #ids + 1])
        end
    end
    pick_agent(nil, true)
end

function M.send_selection()
    local buf = vim.api.nvim_get_current_buf()
    local first, last, text = get_selection()
    send_block(buf, first, last, text)
end

function M.send_diagnostic()
    local buf = vim.api.nvim_get_current_buf()
    local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
    local items = vim.diagnostic.get(buf, { lnum = lnum })
    if #items > 0 then
        return send_diagnostics(items)
    end

    local choices = {
        {
            label = "Current buffer diagnostics",
            get = function()
                return vim.diagnostic.get(buf)
            end,
        },
        { label = "All open buffer diagnostics", get = open_diagnostics },
    }
    vim.ui.select(choices, {
        prompt = "No diagnostic on current line",
        format_item = function(item)
            if not item.items then
                item.items = item.get()
            end
            return item.label .. " (" .. #item.items .. ")"
        end,
    }, function(choice)
        if choice then
            if not choice.items then
                choice.items = choice.get()
            end
            send_diagnostics(choice.items)
        end
    end)
end

local function qf_ref(item)
    if item.bufnr and item.bufnr > 0 and vim.api.nvim_buf_is_valid(item.bufnr) then
        return file_ref(item.bufnr)
    end
    if item.filename and item.filename ~= "" then
        return format_ref(vim.fn.fnamemodify(item.filename, ":."))
    end
end

function M.send_quickfix()
    local items = vim.fn.getqflist()
    if #items == 0 then
        return notify("Quickfix list is empty")
    end

    local lines = {}
    for _, item in ipairs(items) do
        local text = vim.trim(item.text or "")
        local ref = qf_ref(item)
        local loc = item.lnum and item.lnum > 0 and line_ref(item.lnum) or nil
        if ref then
            lines[#lines + 1] = ref .. (loc and (" " .. loc) or "") .. "\n" .. text
        elseif text ~= "" then
            lines[#lines + 1] = text
        end
    end
    send_text(table.concat(lines, "\n"))
end

function M.stop_all()
    stop_all()
end

function M.setup(opts)
    opts = opts or {}
    config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts)

    local group = vim.api.nvim_create_augroup("CustomAgent", { clear = true })
    vim.api.nvim_create_autocmd("TabClosed", {
        group = group,
        callback = function()
            vim.schedule(cleanup_closed_tabs)
        end,
    })

    vim.keymap.set("n", "<c-.>", M.toggle, { desc = "Agent Toggle" })
    vim.keymap.set("n", "<leader>as", M.select, { desc = "Agent Select" })
    vim.keymap.set("x", "<leader>av", M.send_selection, { desc = "Agent Send Selection" })
    vim.keymap.set("n", "<leader>ad", M.send_diagnostic, { desc = "Agent Send Diagnostic" })
    vim.keymap.set("n", "<leader>aq", M.send_quickfix, { desc = "Agent Send Quickfix" })
end

return M
