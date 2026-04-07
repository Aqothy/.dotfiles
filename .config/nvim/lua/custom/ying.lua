local M = {
    history = {},
    state = nil,
    suppress_visual_delete = false,
}

M.config = {
    history_length = 30,
    sync_system_clipboard = true,
    highlight_timeout = 60,
}

local function to_text(content)
    if type(content) == "table" then
        return table.concat(content, "\n")
    end
    return content
end

local function with_temp_register(reg, content, regtype, fn)
    local old_content = vim.fn.getreg(reg, 1, true)
    local old_type = vim.fn.getregtype(reg)

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

function M.highlight(regtype)
    vim.highlight.on_yank({
        timeout = M.config.highlight_timeout,
        event = { operator = "y", regtype = regtype, inclusive = true },
    })
end

-- History management
function M.push(content, regtype)
    if not content or content == "" or (type(content) == "table" and #content == 0) then
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
        register = reg,
        is_visual = is_visual,
        tick = vim.b.changedtick,
    }
end

function M.put(type)
    apply_put(vim.v.register, type, vim.v.count1, nil, is_visual_mode())
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

    local reg = M.state.register
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

function M.setup()
    local group = vim.api.nvim_create_augroup("Ying", { clear = true })

    vim.api.nvim_create_autocmd("TextYankPost", {
        group = group,
        callback = function()
            local event = vim.v.event

            if M.suppress_visual_delete and event.visual and event.operator == "d" then
                return
            end

            if vim.tbl_contains({ "y", "d", "c" }, event.operator) then
                M.push(event.regcontents, event.regtype)
            end
        end,
    })

    if M.config.sync_system_clipboard then
        vim.api.nvim_create_autocmd("FocusGained", {
            group = group,
            callback = function()
                local cb = vim.fn.getreg("+")
                M.push(cb, vim.fn.getregtype("+"))
            end,
        })
    end

    if #M.history == 0 then
        M.push(vim.fn.getreg('"', 1, true), vim.fn.getregtype('"'))
    end
end

return M
