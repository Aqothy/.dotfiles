local fn = vim.fn
local utils = require("custom.utils")

-- go install github.com/fatih/gomodifytags@latest
local function goModTag(operation, opts)
    opts = opts or {}

    if fn.executable("gomodifytags") == 0 then
        vim.notify("gomodifytags not found", vim.log.levels.ERROR)
        return
    end

    if vim.bo.modified then
        vim.notify("File is modified, please save before adding JSON tags", vim.log.levels.WARN)
        return
    end

    local filename = fn.expand("%:p")

    vim.ui.input({
        prompt = "Enter struct name (empty for all structs): ",
    }, function(struct_name)
        -- User canceled the input
        if struct_name == nil then
            return
        end

        local cmd = "gomodifytags -file " .. fn.shellescape(filename)

        if struct_name ~= "" then
            cmd = cmd .. " -struct " .. fn.shellescape(struct_name)
        else
            cmd = cmd .. " -all"
        end

        cmd = cmd .. " -" .. operation .. "-tags json -transform camelcase -w --quiet"

        utils.run_async(cmd, "%m", "GoTag " .. operation, {
            bang = opts.bang,
            on_success = function()
                vim.cmd("checktime")
            end,
        })
    end)
end

vim.keymap.set("n", "<localleader>ta", function()
    goModTag("add", { bang = true })
end, { desc = "Tag Add (json)", buffer = true })

vim.keymap.set("n", "<localleader>tr", function()
    goModTag("remove", { bang = true })
end, { desc = "Tag Remove (json)", buffer = true })
