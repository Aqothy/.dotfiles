/**
 * Code Review Extension (inspired by Codex's /review feature)
 *
 * Usage:
 * - `/review` - show interactive selector
 * - `/review <instructions>` - run a custom-instructions review
 */

import type {
  ExtensionAPI,
  ExtensionCommandContext,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import { DynamicBorder } from "@earendil-works/pi-coding-agent";
import {
  Container,
  type Focusable,
  fuzzyFilter,
  Input,
  type SelectItem,
  SelectList,
  Spacer,
  Text,
} from "@earendil-works/pi-tui";

type ReviewTarget =
  | { type: "baseBranch"; branch: string }
  | { type: "uncommitted" }
  | { type: "commit"; sha: string; title?: string }
  | { type: "custom"; instructions: string };

type ReviewPresetValue = "baseBranch" | "uncommitted" | "commit" | "custom";

type ReviewPreset = { value: ReviewPresetValue; label: string; description: string };

const CUSTOM_REVIEW_PRESET: ReviewPreset = {
  value: "custom",
  label: "Custom review instructions",
  description: "",
};

const REVIEW_PRESETS: ReviewPreset[] = [
  { value: "baseBranch", label: "Review against a base branch", description: "(PR style)" },
  { value: "uncommitted", label: "Review uncommitted changes", description: "" },
  { value: "commit", label: "Review a commit", description: "" },
  CUSTOM_REVIEW_PRESET,
];

const UNCOMMITTED_PROMPT =
  "Review the current code changes (staged, unstaged, and untracked files) and provide prioritized findings.";

const BASE_BRANCH_PROMPT_WITH_MERGE_BASE =
  "Review the code changes against the base branch '{baseBranch}'. The merge base commit for this comparison is {mergeBaseSha}. Run `git diff {mergeBaseSha}` to inspect the changes relative to {baseBranch}. Provide prioritized, actionable findings.";

const BASE_BRANCH_PROMPT_FALLBACK =
  'Review the code changes against the base branch \'{branch}\'. Start by finding the merge diff between the current branch and {branch}\'s upstream e.g. (`git merge-base HEAD "$(git rev-parse --abbrev-ref "{branch}@{upstream}")"`), then run `git diff` against that SHA to see what changes we would merge into the {branch} branch. Provide prioritized, actionable findings.';

const COMMIT_PROMPT_WITH_TITLE =
  'Review the code changes introduced by commit {sha} ("{title}"). Provide prioritized, actionable findings.';

const COMMIT_PROMPT =
  "Review the code changes introduced by commit {sha}. Provide prioritized, actionable findings.";

const REVIEW_GUIDELINES = `# Review guidelines:

You are acting as a reviewer for a proposed code change made by another engineer.

Below are some default guidelines for determining whether the original author would appreciate the issue being flagged.

These are not the final word in determining whether an issue is a bug. In many cases, you will encounter other, more specific guidelines. These may be present elsewhere in a developer message, a user message, a file, or repository instructions. Those guidelines should be considered to override these general instructions.

Here are the general guidelines for determining whether something is a bug and should be flagged.

1. It meaningfully impacts the accuracy, performance, security, or maintainability of the code.
2. The bug is discrete and actionable (i.e. not a general issue with the codebase or a combination of multiple issues).
3. Fixing the bug does not demand a level of rigor that is not present in the rest of the codebase.
4. The bug was introduced in the change being reviewed (pre-existing bugs should not be flagged).
5. The author of the original change would likely fix the issue if they were made aware of it.
6. The bug does not rely on unstated assumptions about the codebase or author's intent.
7. It is not enough to speculate that a change may disrupt another part of the codebase. To be considered a bug, one must identify the other parts of the code that are provably affected.
8. The bug is clearly not just an intentional change by the original author.

When flagging a bug, provide an accompanying comment. Defer to any more specific instructions you encounter.

1. The comment should be clear about why the issue is a bug.
2. The comment should appropriately communicate severity. It should not claim an issue is more severe than it actually is.
3. The comment should be brief. The body should be at most one paragraph.
4. The comment should not include code snippets longer than 3 lines.
5. The comment should clearly and explicitly communicate the scenarios, environments, or inputs that are necessary for the bug to arise.
6. The comment's tone should be matter-of-fact and not accusatory or overly positive. It should read as a helpful assistant suggestion.
7. The comment should be written such that the original author can immediately grasp the idea without close reading.
8. The comment should avoid excessive flattery and comments that are not helpful to the original author.

Below are some more detailed guidelines that you should apply to this specific review.

HOW MANY FINDINGS TO RETURN:

Output all findings that the original author would fix if they knew about them. If there is no finding that a person would definitely want to see and fix, prefer outputting no findings. Do not stop at the first qualifying finding. Continue until you've listed every qualifying finding.

GUIDELINES:

- Ignore trivial style unless it obscures meaning or violates documented standards.
- Use one comment per distinct issue (or a multi-line range if necessary).
- Use suggestion blocks only for concrete replacement code, with minimal lines and no commentary inside the block.
- In every suggestion block, preserve the exact leading whitespace of the replaced lines.
- Do not introduce or remove outer indentation levels unless that is the actual fix.

The findings will be presented as review feedback. Avoid unnecessary location details in the body when the location is already provided. Always keep the line range as short as possible for interpreting the issue. Avoid ranges longer than 5-10 lines; instead, choose the most suitable subrange that pinpoints the problem.

At the beginning of the finding title, tag the bug with a priority level. For example "[P1] Un-padding slices along wrong tensor dimensions".
- [P0] - Drop everything to fix. Blocking release, operations, or major usage. Only use for universal issues that do not depend on assumptions about the inputs.
- [P1] - Urgent. Should be addressed in the next cycle.
- [P2] - Normal. To be fixed eventually.
- [P3] - Low. Nice to have.

At the end of your findings, output an overall correctness verdict of whether or not the patch should be considered correct. Correct implies that existing code and tests will not break, and the patch is free of bugs and other blocking issues. Ignore non-blocking issues such as style, formatting, typos, documentation, and other nits.

OUTPUT FORMAT:

Provide a concise Markdown review with these sections:

## Findings
- For each finding, include a priority-tagged title, file location, short line range, and one-paragraph explanation.
- If there are no findings, say "No findings."

## Overall Correctness
- Use exactly one of: "patch is correct" or "patch is incorrect".

## Overall Explanation
- Provide 1-3 sentences justifying the verdict.

Do not generate a PR fix or apply code changes.`;

async function getMergeBase(pi: ExtensionAPI, branch: string): Promise<string | null> {
  try {
    const { stdout: upstream, code: upstreamCode } = await pi.exec("git", [
      "rev-parse",
      "--abbrev-ref",
      `${branch}@{upstream}`,
    ]);

    if (upstreamCode === 0 && upstream.trim()) {
      const { stdout: mergeBase, code } = await pi.exec("git", [
        "merge-base",
        "HEAD",
        upstream.trim(),
      ]);
      if (code === 0 && mergeBase.trim()) {
        return mergeBase.trim();
      }
    }

    const { stdout: mergeBase, code } = await pi.exec("git", ["merge-base", "HEAD", branch]);
    if (code === 0 && mergeBase.trim()) {
      return mergeBase.trim();
    }
  } catch {
    return null;
  }

  return null;
}

async function getLocalBranches(pi: ExtensionAPI): Promise<string[]> {
  const { stdout, code } = await pi.exec("git", ["branch", "--format=%(refname:short)"]);
  if (code !== 0) return [];
  return stdout
    .trim()
    .split("\n")
    .map((branch) => branch.trim())
    .filter(Boolean);
}

async function getRecentCommits(
  pi: ExtensionAPI,
  limit = 100,
): Promise<Array<{ sha: string; title: string }>> {
  const { stdout, code } = await pi.exec("git", ["log", "--oneline", "-n", String(limit)]);
  if (code !== 0) return [];

  return stdout
    .trim()
    .split("\n")
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => {
      const [sha, ...rest] = line.split(" ");
      return { sha, title: rest.join(" ") };
    });
}

async function getCurrentBranch(pi: ExtensionAPI): Promise<string | null> {
  const { stdout, code } = await pi.exec("git", ["branch", "--show-current"]);
  return code === 0 && stdout.trim() ? stdout.trim() : null;
}

async function getDefaultBranch(pi: ExtensionAPI): Promise<string> {
  const { stdout, code } = await pi.exec("git", [
    "symbolic-ref",
    "refs/remotes/origin/HEAD",
    "--short",
  ]);
  if (code === 0 && stdout.trim()) {
    return stdout.trim().replace("origin/", "");
  }

  const branches = await getLocalBranches(pi);
  if (branches.includes("main")) return "main";
  if (branches.includes("master")) return "master";
  return "main";
}

async function buildReviewPrompt(pi: ExtensionAPI, target: ReviewTarget): Promise<string> {
  switch (target.type) {
    case "baseBranch": {
      const mergeBase = await getMergeBase(pi, target.branch);
      return mergeBase
        ? BASE_BRANCH_PROMPT_WITH_MERGE_BASE.replace(/{baseBranch}/g, target.branch).replace(
            /{mergeBaseSha}/g,
            mergeBase,
          )
        : BASE_BRANCH_PROMPT_FALLBACK.replace(/{branch}/g, target.branch);
    }

    case "uncommitted":
      return UNCOMMITTED_PROMPT;

    case "commit":
      return target.title
        ? COMMIT_PROMPT_WITH_TITLE.replace("{sha}", target.sha).replace("{title}", target.title)
        : COMMIT_PROMPT.replace("{sha}", target.sha);

    case "custom":
      return target.instructions.trim();
  }
}

function getUserFacingHint(target: ReviewTarget): string {
  switch (target.type) {
    case "baseBranch":
      return `changes against '${target.branch}'`;
    case "uncommitted":
      return "current changes";
    case "commit": {
      const shortSha = target.sha.slice(0, 7);
      return target.title ? `commit ${shortSha}: ${target.title}` : `commit ${shortSha}`;
    }
    case "custom":
      return "custom review instructions";
  }
}

async function showReviewSelector(
  pi: ExtensionAPI,
  ctx: ExtensionContext,
): Promise<ReviewTarget | null> {
  while (true) {
    const result = await ctx.ui.custom<ReviewPresetValue | null>((tui, theme, _kb, done) => {
      const container = new Container();
      container.addChild(new DynamicBorder((str) => theme.fg("accent", str)));
      container.addChild(new Text(theme.fg("accent", theme.bold("Select a review preset"))));

      const selectList = new SelectList(REVIEW_PRESETS, REVIEW_PRESETS.length, {
        selectedPrefix: (text) => theme.fg("accent", text),
        selectedText: (text) => theme.fg("accent", text),
        description: (text) => theme.fg("muted", text),
        scrollInfo: (text) => theme.fg("dim", text),
        noMatch: (text) => theme.fg("warning", text),
      });

      selectList.onSelect = (item) => done(item.value as ReviewPresetValue);
      selectList.onCancel = () => done(null);

      container.addChild(selectList);
      container.addChild(new Text(theme.fg("dim", "Press enter to confirm or esc to cancel")));
      container.addChild(new DynamicBorder((str) => theme.fg("accent", str)));

      return {
        render(width: number) {
          return container.render(width);
        },
        invalidate() {
          container.invalidate();
        },
        handleInput(data: string) {
          selectList.handleInput(data);
          tui.requestRender();
        },
      };
    });

    if (!result) return null;

    switch (result) {
      case "baseBranch": {
        const target = await showBranchSelector(pi, ctx);
        if (target) return target;
        break;
      }
      case "uncommitted":
        return { type: "uncommitted" };
      case "commit": {
        const target = await showCommitSelector(pi, ctx);
        if (target) return target;
        break;
      }
      case "custom": {
        const target = await showCustomInstructionsInput(ctx);
        if (target) return target;
        break;
      }
    }
  }
}

async function showBranchSelector(
  pi: ExtensionAPI,
  ctx: ExtensionContext,
): Promise<ReviewTarget | null> {
  const branches = await getLocalBranches(pi);
  const currentBranch = await getCurrentBranch(pi);
  const defaultBranch = await getDefaultBranch(pi);
  const candidateBranches = currentBranch
    ? branches.filter((branch) => branch !== currentBranch)
    : branches;

  if (candidateBranches.length === 0) {
    ctx.ui.notify("No base branches found", "error");
    return null;
  }

  const sortedBranches = candidateBranches.sort((a, b) => {
    if (a === defaultBranch) return -1;
    if (b === defaultBranch) return 1;
    return a.localeCompare(b);
  });

  const items: SelectItem[] = sortedBranches.map((branch) => ({
    value: branch,
    label: branch,
    description: branch === defaultBranch ? "(default)" : "",
  }));

  const branch = await showSearchableList(ctx, "Select base branch", items);
  return branch ? { type: "baseBranch", branch } : null;
}

async function showCommitSelector(
  pi: ExtensionAPI,
  ctx: ExtensionContext,
): Promise<ReviewTarget | null> {
  const commits = await getRecentCommits(pi);
  if (commits.length === 0) {
    ctx.ui.notify("No commits found", "error");
    return null;
  }

  const items: SelectItem[] = commits.map((commit) => ({
    value: commit.sha,
    label: `${commit.sha.slice(0, 7)} ${commit.title}`,
    description: "",
  }));

  const sha = await showSearchableList(ctx, "Select commit to review", items);
  const commit = commits.find((item) => item.sha === sha);
  return commit ? { type: "commit", sha: commit.sha, title: commit.title } : null;
}

async function showCustomInstructionsInput(ctx: ExtensionContext): Promise<ReviewTarget | null> {
  const instructions = await ctx.ui.editor("Enter custom review instructions:", "");
  const trimmed = instructions?.trim();
  return trimmed ? { type: "custom", instructions: trimmed } : null;
}

async function showSearchableList(
  ctx: ExtensionContext,
  title: string,
  items: SelectItem[],
): Promise<string | null> {
  return ctx.ui.custom<string | null>((tui, theme, keybindings, done) => {
    const container = new Container();
    container.addChild(new DynamicBorder((str) => theme.fg("accent", str)));
    container.addChild(new Text(theme.fg("accent", theme.bold(title))));

    const searchInput = new Input();
    container.addChild(searchInput);
    container.addChild(new Spacer(1));

    const listContainer = new Container();
    container.addChild(listContainer);
    container.addChild(
      new Text(theme.fg("dim", "Type to filter • enter to select • esc to cancel")),
    );
    container.addChild(new DynamicBorder((str) => theme.fg("accent", str)));

    let filteredItems = items;
    let selectList: SelectList | null = null;

    const updateList = () => {
      listContainer.clear();
      if (filteredItems.length === 0) {
        listContainer.addChild(new Text(theme.fg("warning", "  No matches")));
        selectList = null;
        return;
      }

      selectList = new SelectList(filteredItems, Math.min(filteredItems.length, 10), {
        selectedPrefix: (text) => theme.fg("accent", text),
        selectedText: (text) => theme.fg("accent", text),
        description: (text) => theme.fg("muted", text),
        scrollInfo: (text) => theme.fg("dim", text),
        noMatch: (text) => theme.fg("warning", text),
      });

      selectList.onSelect = (item) => done(String(item.value));
      selectList.onCancel = () => done(null);
      listContainer.addChild(selectList);
    };

    const applyFilter = () => {
      const query = searchInput.getValue();
      filteredItems = query
        ? fuzzyFilter(
            items,
            query,
            (item) => `${item.label} ${item.value} ${item.description ?? ""}`,
          )
        : items;
      updateList();
    };

    applyFilter();

    const component: Focusable & {
      render(width: number): string[];
      invalidate(): void;
      handleInput(data: string): void;
    } = {
      get focused() {
        return searchInput.focused;
      },
      set focused(value: boolean) {
        searchInput.focused = value;
      },
      render(width: number) {
        return container.render(width);
      },
      invalidate() {
        container.invalidate();
      },
      handleInput(data: string) {
        if (
          keybindings.matches(data, "tui.select.up") ||
          keybindings.matches(data, "tui.select.down") ||
          keybindings.matches(data, "tui.select.confirm") ||
          keybindings.matches(data, "tui.select.cancel")
        ) {
          if (selectList) {
            selectList.handleInput(data);
          } else if (keybindings.matches(data, "tui.select.cancel")) {
            done(null);
          }
          tui.requestRender();
          return;
        }

        searchInput.handleInput(data);
        applyFilter();
        tui.requestRender();
      },
    };

    return component;
  });
}

async function executeReview(
  pi: ExtensionAPI,
  ctx: ExtensionCommandContext,
  target: ReviewTarget,
): Promise<void> {
  const prompt = await buildReviewPrompt(pi, target);
  const hint = getUserFacingHint(target);
  const fullPrompt = `${REVIEW_GUIDELINES}\n\n---\n\nPlease perform a code review with the following focus:\n\n${prompt}`;

  if (ctx.isIdle()) {
    ctx.ui.notify(`Starting review: ${hint}`, "info");
    pi.sendUserMessage(fullPrompt);
  } else {
    ctx.ui.notify(`Queued review: ${hint}`, "info");
    pi.sendUserMessage(fullPrompt, { deliverAs: "followUp" });
  }
}

export default function reviewExtension(pi: ExtensionAPI) {
  pi.registerCommand("review", {
    description: "Review code changes",
    handler: async (args, ctx) => {
      const customInstructions = args?.trim();
      if (!customInstructions && ctx.mode !== "tui") {
        ctx.ui.notify(
          "Review selector requires TUI mode; pass instructions as /review <instructions>",
          "error",
        );
        return;
      }

      const target = customInstructions
        ? { type: "custom" as const, instructions: customInstructions }
        : await selectReviewTarget(pi, ctx);

      if (!target) {
        ctx.ui.notify("Review cancelled", "info");
        return;
      }

      await executeReview(pi, ctx, target);
    },
  });
}

async function selectReviewTarget(
  pi: ExtensionAPI,
  ctx: ExtensionCommandContext,
): Promise<ReviewTarget | null> {
  return showReviewSelector(pi, ctx);
}
