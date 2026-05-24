local M = {
    history = {},
    state = nil,
    suppress_visual_delete = false,
    system_clipboard_text = nil,
    system_clipboard_type = nil,
}

M.config = {
    history_length = 30,
    highlight_timeout = 60,
    sync_system_clipboard = true,
}

local CYCLE_REGISTER = "x"

local function is_empty_content(content)
    return not content or content == "" or (type(content) == "table" and #content == 0)
end

local function to_text(content)
    if type(content) == "table" then
        return table.concat(content, "\n")
    end
    return content
end

local function read_register(reg)
    return vim.fn.getreg(reg, 1, true), vim.fn.getregtype(reg)
end

local function with_temp_register(reg, content, regtype, fn)
    local old_content, old_type = read_register(reg)

    vim.fn.setreg(reg, content, regtype)
    local ok, result = pcall(fn)
    vim.fn.setreg(reg, old_content, old_type)

    if not ok then
        error(result)
    end

    return result
end

local function is_visual_mode()
    local mode = vim.fn.mode()
    return mode == "v" or mode == "V" or mode == "\22"
end

local function sync_system_clipboard()
    local content, regtype = read_register("+")
    if is_empty_content(content) then
        return false
    end

    local text = to_text(content)
    if text == M.system_clipboard_text and regtype == M.system_clipboard_type then
        return false
    end

    M.system_clipboard_text = text
    M.system_clipboard_type = regtype
    vim.fn.setreg('"', content, regtype)
    M.push(content, regtype)

    return true
end

local function mark_system_clipboard(content, regtype)
    if is_empty_content(content) then
        return
    end

    M.system_clipboard_text = to_text(content)
    M.system_clipboard_type = regtype
end

local function is_default_register(reg)
    return reg == nil or reg == "" or reg == '"'
end

function M.highlight(regtype)
    vim.highlight.on_yank({
        timeout = M.config.highlight_timeout,
        event = { operator = "y", regtype = regtype, inclusive = true },
    })
end

-- History management
function M.push(content, regtype)
    if is_empty_content(content) then
        return
    end

    local lines = type(content) == "table" and content or vim.split(content, "\n")
    local text = to_text(lines)

    -- Deduplicate against the most recent entry
    if M.history[1] and to_text(M.history[1].content) == text then
        return
    end

    table.insert(M.history, 1, {
        content = lines,
        type = regtype,
    })

    if #M.history > M.config.history_length then
        table.remove(M.history)
    end
end

local function apply_put(reg, type, count, index, is_visual)
    if is_visual then
        vim.cmd([[execute "normal! \<esc>"]])
    end

    local visual_prefix = is_visual and "gv" or ""
    local ok, err = pcall(function()
        vim.cmd(('silent normal! %s"%s%d%s'):format(visual_prefix, reg, count, type))
    end)

    if not ok then
        error(err)
    end

    local regtype = vim.fn.getregtype(reg)
    M.highlight(regtype)

    local resolved_index = index
    if not resolved_index then
        resolved_index = is_visual and math.min(2, #M.history) or 1
    end

    M.state = {
        count = count,
        index = resolved_index,
        type = type,
        is_visual = is_visual,
        tick = vim.b.changedtick,
    }
end

function M.put(type)
    local reg = vim.v.register

    if M.config.sync_system_clipboard and is_default_register(reg) then
        sync_system_clipboard()
    end

    apply_put(reg, type, vim.v.count1, nil, is_visual_mode())
end

function M.cycle(dir)
    -- Check buffer hasn't changed since last paste
    if not M.state or M.state.tick ~= vim.b.changedtick or #M.history <= 1 then
        return
    end

    local new_idx = M.state.index + dir

    if new_idx < 1 then
        new_idx = #M.history
    elseif new_idx > #M.history then
        new_idx = 1
    end

    local entry = M.history[new_idx]
    vim.cmd("silent! undo")

    local reg = CYCLE_REGISTER
    M.suppress_visual_delete = true
    local ok, err = pcall(function()
        with_temp_register(reg, entry.content, entry.type, function()
            apply_put(reg, M.state.type, M.state.count, new_idx, M.state.is_visual)
        end)
    end)
    M.suppress_visual_delete = false

    if not ok then
        error(err)
    end
end

function M.picker()
    if #M.history == 0 then
        return
    end

    local items = {}
    for _, entry in ipairs(M.history) do
        table.insert(items, to_text(entry.content))
    end

    vim.ui.select(items, { prompt = "Yank History:" }, function(_, idx)
        if not idx then
            return
        end
        local entry = M.history[idx]
        local reg = '"'
        with_temp_register(reg, entry.content, entry.type, function()
            apply_put(reg, "p", 1, idx, false)
        end)
    end)
end

function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})

    local group = vim.api.nvim_create_augroup("Ying", { clear = true })

    vim.api.nvim_create_autocmd("TextYankPost", {
        group = group,
        callback = function()
            local event = vim.v.event

            if M.suppress_visual_delete and event.visual and event.operator == "d" then
                return
            end

            if M.config.sync_system_clipboard then
                if event.operator == "y" and is_default_register(event.regname) then
                    vim.fn.setreg("+", event.regcontents, event.regtype)
                    mark_system_clipboard(event.regcontents, event.regtype)
                elseif event.regname == "+" then
                    mark_system_clipboard(event.regcontents, event.regtype)
                end
            end

            if vim.tbl_contains({ "y", "d", "c" }, event.operator) then
                M.push(event.regcontents, event.regtype)
            end
        end,
    })

    if M.config.sync_system_clipboard then
        sync_system_clipboard()
    end
end

return M
