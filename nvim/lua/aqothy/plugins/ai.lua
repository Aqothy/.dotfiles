return {
    {
        "github/copilot.vim",
        event = "BufReadPost",
        cmd = "Copilot",
        init = function()
            vim.g.copilot_lsp_settings = {
                telemetry = {
                    telemetryLevel = "off",
                },
            }
            vim.g.copilot_settings = { selectedCompletionModel = "gpt-4o-copilot" }
            vim.g.copilot_filetypes = {
                ["*"] = true,
                dotenv = false,
            }
        end,
    },
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            { "nvim-lua/plenary.nvim" },
        },
        cmd = { "CodeCompanion", "CodeCompanionChat" },
        opts = function()
            local function switch_model(target, adapter)
                local bufnr = vim.api.nvim_get_current_buf()
                local chat_strategy = require("codecompanion.strategies.chat")
                if type(chat_strategy.buf_get_chat) ~= "function" then
                    return nil
                end
                local chat = chat_strategy.buf_get_chat(bufnr)
                if not chat or not chat.adapter then
                    vim.notify("No CodeCompanion chat in this buffer", vim.log.levels.WARN)
                    return
                end

                chat.adapter = require("codecompanion.adapters").resolve(adapter or "copilot")
                chat.ui.adapter = chat.adapter
                chat:apply_model(target)
                chat:apply_settings()
                vim.notify(string.format("Switched model to %s", target), vim.log.levels.INFO)
            end

            return {
                opts = {
                    system_prompt = function()
                        return string.format(
                            [[
You are a highly skilled software engineer with extensive knowledge in many programming languages, frameworks, design patterns, and best practices.

## Communication

1. Be conversational but professional.
2. Refer to the user in the second person and yourself in the first person.
3. Format your responses in markdown. Use backticks to format file, directory, function, and class names.
4. NEVER lie or make things up.
5. Refrain from apologizing all the time when results are unexpected. Instead, just try your best to proceed or explain the circumstances to the user without apologizing.

## Tool Use

1. Make sure to adhere to the tools schema.
2. Provide every required argument.
3. DO NOT use tools to access items that are already available in the context section.
4. Use only the tools that are currently available.
5. DO NOT use a tool that is not available just because it appears in the conversation. This means the user turned it off.
6. NEVER run commands that don't terminate on their own such as web servers (like `npm run start`, `npm run dev`, `python -m http.server`, etc) or file watchers.
7. Avoid HTML entity escaping - use plain characters instead.

## Searching and Reading

If you are unsure how to fulfill the user's request, gather more information with tool calls and/or clarifying questions.

If appropriate, use tool calls to explore the current project, which contains the following root directories:

- Bias towards not asking the user for help if you can find the answer yourself.
- When providing paths to tools, the path should always start with the name of a project root directory listed above.
- Before you read or edit a file, you must first find the full path. DO NOT ever guess a file path!
- When looking for symbols in the project, prefer the `grep_search` tool.
- As you learn about the structure of the project, use that information to scope `grep_search` searches to targeted subtrees of the project.
- The user might specify a partial file path. If you don't know the full path, use `file_search` (not `grep_search`) before you read the file.
You are being tasked with providing a response, but you have no ability to use tools or to read or write any aspect of the user's system (other than any context the user might have provided to you).

As such, if you need the user to perform any actions for you, you must request them explicitly. Bias towards giving a response to the best of your ability, and then making requests for the user to take action (e.g. to give you more context) only optionally.

The one exception to this is if the user references something you don't know about - for example, the name of a source code file, function, type, or other piece of code that you have no awareness of. In this case, you MUST NOT MAKE SOMETHING UP, or assume you know what that thing is or how it works. Instead, you must ask the user for clarification rather than giving a response.

## Code Block Formatting

Whenever you mention a code block, you MUST use the following format:
```language
(code goes here)
```
The `language` should be the programming language of the code block (e.g., javascript, python, css, html, etc.).

## Fixing Diagnostics

1. Make 1-2 attempts at fixing diagnostics, then defer to the user.
2. Never simplify code you've written just to solve diagnostics. Complete, mostly correct code is more valuable than perfect code that doesn't solve the problem.

## Debugging

When debugging, only make code changes if you are certain that you can solve the problem.
Otherwise, follow debugging best practices:
1. Address the root cause instead of the symptoms.
2. Add descriptive logging statements and error messages to track variable and code state.
3. Add test functions and statements to isolate the problem.

## Calling External APIs

1. Unless explicitly requested by the user, use the best suited external APIs and packages to solve the task. There is no need to ask the user for permission.
2. When selecting which version of an API or package to use, choose one that is compatible with the user's dependency management file(s). If no such file exists or if the package is not present, use the latest version that is in your training data.
3. If an external API requires an API Key, be sure to point this out to the user. Adhere to best security practices (e.g. DO NOT hardcode an API key in a place where it can be exposed)

## System Information

Operating System: %s
]],
                            vim.uv.os_uname().sysname
                        )
                    end,
                },
                adapters = {
                    gemini = function()
                        return require("codecompanion.adapters").extend("gemini", {
                            env = {
                                api_key = "cmd:cat ~/gemini_api.txt",
                            },
                        })
                    end,
                    copilot = function()
                        return require("codecompanion.adapters").extend("copilot", {
                            schema = {
                                max_tokens = {
                                    default = 128000,
                                },
                            },
                        })
                    end,
                },
                strategies = {
                    chat = {
                        adapter = {
                            -- name = "gemini",
                            -- model = "gemini-2.5-pro",
                            name = "copilot",
                            model = "claude-sonnet-4",
                        },
                        roles = {
                            user = "Aqothy",
                        },
                        keymaps = {
                            gemini = {
                                modes = { n = "<leader>1" },
                                description = "Toggle Gemini Chat",
                                callback = function()
                                    switch_model("gemini-2.5-pro", "gemini")
                                end,
                            },
                            claude = {
                                modes = { n = "<leader>2" },
                                description = "Toggle Claude Chat",
                                callback = function()
                                    switch_model("claude-sonnet-4")
                                end,
                            },
                            gpt = {
                                modes = { n = "<leader>3" },
                                description = "Toggle Gpt Chat",
                                callback = function()
                                    switch_model("gpt-4.1")
                                end,
                            },
                        },
                    },
                    inline = {
                        adapter = {
                            name = "copilot",
                            model = "gpt-4.1",
                        },
                    },
                },
                display = {
                    chat = {
                        intro_message = "",
                        show_header_separator = true,
                        window = {
                            opts = {
                                number = false,
                                relativenumber = false,
                            },
                        },
                    },
                },
            }
        end,
        keys = {
            { "<leader>ac", ":CodeCompanionActions<CR>", desc = "Open the action palette", mode = { "n", "x" }, silent = true },
            { "<Leader>ai", ":CodeCompanionChat Toggle<CR>", desc = "Toggle a chat buffer", silent = true },
            { "<leader>aa", ":CodeCompanionChat Add<CR>", desc = "Add code to a chat buffer", mode = "x", silent = true },
        },
    },
}
