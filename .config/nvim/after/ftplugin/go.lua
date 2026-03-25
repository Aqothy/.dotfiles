local fn = vim.fn
local utils = require("custom.tasks")

-- go install github.com/fatih/gomodifytags@latest
local function goModTag(operation)
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

        utils.run(cmd, {
            title = "GoTag " .. operation,
            on_success = function()
                vim.notify("GoTag " .. operation .. ": Success", vim.log.levels.INFO)
            end,
            on_failure = function(result)
                vim.notify(
                    string.format(
                        "GoTag %s: Failed\n%s",
                        operation,
                        result.stderr ~= "" and result.stderr or "Unknown error"
                    ),
                    vim.log.levels.ERROR
                )
            end,
        })
    end)
end

vim.keymap.set("n", "<localleader>ja", function()
    goModTag("add")
end, { desc = "Tag Add (json)", buf = 0 })

vim.keymap.set("n", "<localleader>jr", function()
    goModTag("remove")
end, { desc = "Tag Remove (json)", buf = 0 })
