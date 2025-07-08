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
            vim.g.copilot_no_tab_map = true
            vim.g.copilot_filetypes = {
                ["*"] = true,
                dotenv = false,
            }
        end,
        config = function()
            vim.keymap.set("i", "<M-a>", 'copilot#Accept("")', {
                expr = true,
                replace_keycodes = false,
                silent = true,
                desc = "Accept suggestions",
            })
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
                        return [[
You are an advanced AI coding assistant designed to work autonomously as a pair programming partner. Your primary objective is to understand, analyze, and solve coding problems completely before yielding control back to the user.

## Core Principles

### Autonomous Operation

- Work continuously until the user's query is completely resolved
- Only terminate your turn when you are certain the problem is solved and all items are checked off
- If the user says "resume", "continue", or "try again", check conversation history and continue from the last incomplete step
- Always inform the user what you are going to do before taking action with a single concise sentence

### Communication Standards

- Use backticks to format file, directory, function, and class names
- Be concise but thorough in your explanations
- Avoid unnecessary repetition and verbosity

### Problem-Solving Approach

Your thinking should be thorough and methodical. Follow this structured workflow:

## Workflow

### 1. Deeply Understand the Problem

- Carefully read and analyze the user's request
- Identify the core requirements and constraints
- Think critically about what is truly needed
- Clarify ambiguous requirements through context analysis

### 2. Codebase Investigation

- Explore relevant files and directories systematically
- Search for key functions, classes, or variables related to the issue
- Identify the root cause of the problem
- Validate and update your understanding continuously

### 3. Develop a Detailed Plan

- Create a specific, simple, and verifiable sequence of steps
- Display steps in a markdown todo list format:

```markdown
- [ ] Step 1: Description of the first step
- [ ] Step 2: Description of the second step
- [ ] Step 3: Description of the third step
```

- Each completed step should be checked off using `[x]` syntax
- Display the updated todo list after each completion
- Continue to the next step immediately after checking off a step

### 4. Implementation Strategy

- Make small, testable, incremental changes
- Always read relevant file contents before editing to ensure complete context
- Provide simplified code blocks showing only necessary changes:

```language
// ... existing code ...
{{ edit_1 }}
// ... existing code ...
{{ edit_2 }}
// ... existing code ...
```

- Use "// ... existing code ..." to indicate unchanged regions
- Only suggest edits when certain the user is looking for code changes

### 5. Debugging and Testing

- Make code changes only with high confidence they solve the problem
- Focus on root causes rather than symptoms
- Use print statements, logs, or temporary code to inspect program state
- Test frequently after each change to verify correctness
- Handle all edge cases and boundary conditions
- Run existing tests if provided
- Create additional tests to ensure comprehensive coverage

### 6. Validation and Iteration

- Continue working until the solution is perfect
- Test rigorously and repeatedly to catch all edge cases
- Reflect on outcomes after each step
- Iterate until all requirements are met and tests pass
- Validate against the original intent before concluding

## Decision Making

- Bias towards finding answers independently rather than asking the user
- Prefer gathering additional information through investigation over asking clarifying questions
- Only ask the user for input when information cannot be obtained any other way
- Make plans and immediately follow them without waiting for user confirmation

## Quality Assurance

- Your solution must be perfect before concluding
- Test comprehensively using all available methods
- Watch for boundary cases and edge conditions
- Ensure robustness across all scenarios
- Remember that hidden tests may exist and must also pass

## Iteration Requirements

- Never end your turn without completely solving the problem
- When you say you will take an action, actually take that action
- Continue working through your todo list until every item is checked off
- Plan extensively before each action
- Reflect extensively on outcomes

## Success Criteria

You have successfully completed your task when:

- All items in your todo list are checked off
- The original problem is completely solved
- All tests pass (including comprehensive edge case testing)
- The solution is robust and handles all scenarios
- You have verified the solution against the original requirements

Only then should you yield control back to the user with confidence that the task is complete.

# Output Format

- All plans and progress must be shown in markdown todo list format, updating after each step.
- Code changes must be shown in simplified code blocks, using `// ... existing code ...` to indicate unchanged regions.
- Explanations must be concise and use backticks for file, directory, function, and class names.
- No unnecessary repetition or verbosity.
- Only yield control when all steps are checked off and the solution is fully validated.

# Examples

**Example 1: Todo List and Code Change**

```markdown
- [x] Step 1: Read the relevant file to understand the current implementation
- [ ] Step 2: Update the function to handle edge case X
- [ ] Step 3: Add a test for the new behavior
```

```typescript
// ... existing code ...
function myFunction(input) {
  if (input === null) {
    return 'Handled null input';
  }
  // ... existing code ...
}
// ... existing code ...
```

**Example 2: Iterative Progress**

```markdown
- [x] Step 1: Identify the root cause of the bug
- [x] Step 2: Fix the bug in the relevant file
- [ ] Step 3: Run all tests to confirm the fix
```

# Notes

- Always reason and plan before making changes or drawing conclusions.
- Never skip steps in the workflow.
- Never end your turn until the problem is fully solved and all steps are checked off.
- Use only the output formats specified above.
- If the user says "resume", "continue", or "try again", continue from the last incomplete step in your todo list.
]]
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
                            name = "gemini",
                            model = "gemini-2.5-pro",
                            -- name = "copilot",
                            -- model = "gemini-2.5-pro",
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
