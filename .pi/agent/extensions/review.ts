/**
 * Code Review Extension (inspired by Codex's /review feature)
 *
 * Usage:
 * - `/review` - show interactive selector (structured targets can add optional focus instructions)
 * - `/review <instructions>` - run a custom review in the current session
 * - `/review-loop [instructions]` - repeatedly delegate review, validate findings, and fix them
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

type StructuredReviewTarget =
  | { type: "baseBranch"; branch: string; focus?: string }
  | { type: "uncommitted"; focus?: string }
  | { type: "commit"; sha: string; title?: string; focus?: string };

type ReviewTarget = StructuredReviewTarget | { type: "custom"; instructions: string };

type ReviewPresetValue = "baseBranch" | "uncommitted" | "commit" | "custom";

type ReviewPreset = {
  value: ReviewPresetValue;
  label: string;
  description: string;
};

const CUSTOM_REVIEW_PRESET: ReviewPreset = {
  value: "custom",
  label: "Custom review instructions",
  description: "",
};

const REVIEW_PRESETS: ReviewPreset[] = [
  {
    value: "baseBranch",
    label: "Review against a base branch",
    description: "(PR style)",
  },
  {
    value: "uncommitted",
    label: "Review uncommitted changes",
    description: "",
  },
  { value: "commit", label: "Review a commit", description: "" },
  CUSTOM_REVIEW_PRESET,
];

const UNCOMMITTED_PROMPT =
  "Review the current code changes (staged, unstaged, and untracked files) and provide prioritized findings.";

const REVIEW_FOCUS_INPUT_PROMPT = "Enter optional focused review instructions (blank = none):";

const BASE_BRANCH_PROMPT_WITH_MERGE_BASE =
  "Review the code changes against the base branch '{baseBranch}'. The merge base commit for this comparison is {mergeBaseSha}. Run `git diff {mergeBaseSha}` to inspect the changes relative to {baseBranch}. Provide prioritized, actionable findings.";

const BASE_BRANCH_PROMPT_FALLBACK =
  'Review the code changes against the base branch \'{branch}\'. Start by finding the merge diff between the current branch and {branch}\'s upstream e.g. (`git merge-base HEAD "$(git rev-parse --abbrev-ref "{branch}@{upstream}")"`), then run `git diff` against that SHA to see what changes we would merge into the {branch} branch. Provide prioritized, actionable findings.';

const COMMIT_PROMPT_WITH_TITLE =
  'Review the code changes introduced by commit {sha} ("{title}"). Provide prioritized, actionable findings.';

const COMMIT_PROMPT =
  "Review the code changes introduced by commit {sha}. Provide prioritized, actionable findings.";

const REVIEW_LOOP_INSTRUCTIONS = `# Review and Fix Loop

Run a review-and-fix loop for the review target below.

For each iteration:
1. Spawn subagents with the \`subagent\` tool in \`single\` or \`parallel\` mode using the user-level \`general\` agent. Give each subagent the complete review target, any focus instructions, and the complete **Subagent Review Rubric** below. The subagent task is read-only; do not ask it to edit files.
2. Check every returned finding against the code and the requested diff. Keep only high-confidence issues that can realistically affect day-to-day use. Reject pre-existing issues, intentional behavior, cosmetic nits, highly improbable edge cases, and false positives.
3. If no valid findings remain, stop.
4. Fix every valid finding yourself with the simplest maintainable change that addresses the root cause. Run focused checks or tests when practical.
5. Spawn a fresh general subagent with the same complete rubric and repeat against the resulting code. Do not assume an earlier fix is correct without the next independent review.

Continue until a fresh review returns no findings or only findings you have verified as invalid. Do not delegate fixes to subagents. At the end, summarize the valid findings fixed, rejected findings if noteworthy, and verification performed.`;

const REVIEW_RUBRIC = `# Code Review

Act as a rigorous reviewer for a proposed change made by another engineer. Inspect the repository and the requested diff directly. This is a read-only review: do not edit files, apply fixes, or generate a PR patch.

## Review standard

Flag discrete, actionable issues introduced by the reviewed change that materially affect correctness, security, performance, compatibility, or maintainability and that the author would likely fix. Do not flag pre-existing problems, intentional behavior changes, speculative impact, or cosmetic nits. When claiming an affected caller or path, identify it concretely.

Audit both behavior and design, but report a design concern only when the change creates a concrete maintenance risk or obscures an important invariant. Do not reject working code merely because another style is possible.

For every meaningful change, ask:
- Does it introduce an incorrect state, missed caller, unsafe boundary, compatibility break, or failure path?
- Can fewer concepts express the same behavior without hiding policy in scattered conditionals?
- Is state and policy owned by the canonical module, or duplicated across layers?
- Does an abstraction remove meaningful complexity, or merely add a wrapper, mode, flag, or indirection?
- Can independent operations run concurrently, and can related updates leave partially applied state?

Prefer deletion, direct typed contracts, canonical helpers, focused modules, and explicit dispatch over generic machinery. Treat a change that pushes a file from below 1,000 lines to above 1,000 as a decomposition warning, not an automatic finding.

Maintain a high bar. A preference without a concrete failure scenario, maintenance cost, and actionable remedy is not a finding. Prefer a small set of high-confidence findings over exhaustive commentary.

## Finding format

Each finding must:

- Start with \`[P0]\`, \`[P1]\`, \`[P2]\`, or \`[P3]\`.
- Include the file path and the shortest useful line range, preferably overlapping the diff.
- Explain in one concise paragraph why it matters, the scenario in which it matters, and the structural direction of the remedy.
- Avoid snippets over three lines and avoid praise, filler, or softened language.

Priorities: P0 blocks release or major usage universally; P1 is urgent; P2 is normal; P3 is low priority but still worth fixing. Return every qualifying finding, but prefer a small set of high-conviction comments over cosmetic noise.

## Required output

Output Markdown exactly in this shape:

## Findings
- For each finding: priority-tagged title, file location, short line range, and one-paragraph explanation.
- If none qualify, write \`No findings.\`

## Overall Correctness
- Use exactly one of: \`patch is correct\` or \`patch is incorrect\`.

## Overall Explanation
- Give 1-3 sentences justifying the verdict.

\`patch is correct\` requires no behavior-breaking issue or blocking structural regression under this review standard.`;

const REVIEW_LOOP_PROMPT = `${REVIEW_LOOP_INSTRUCTIONS}

## Subagent Review Rubric

${REVIEW_RUBRIC}

## Review Target

{target}`;

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

function getReviewFocus(target: ReviewTarget): string | null {
  if (target.type === "custom") return null;
  return target.focus?.trim() || null;
}

function getUserFacingHint(target: ReviewTarget): string {
  const focusSuffix = getReviewFocus(target) ? " with focus" : "";

  switch (target.type) {
    case "baseBranch":
      return `changes against '${target.branch}'${focusSuffix}`;
    case "uncommitted":
      return `current changes${focusSuffix}`;
    case "commit": {
      const shortSha = target.sha.slice(0, 7);
      return `${target.title ? `commit ${shortSha}: ${target.title}` : `commit ${shortSha}`}${focusSuffix}`;
    }
    case "custom":
      return "focus on the following";
  }
}

async function showReviewSelector(
  pi: ExtensionAPI,
  ctx: ExtensionContext,
): Promise<ReviewTarget | null> {
  while (true) {
    const result = await ctx.ui.custom<ReviewPresetValue | null>((tui, theme, _kb, done) => {
      const container = new Container();
      container.addChild(new DynamicBorder((str: string) => theme.fg("accent", str)));
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
      container.addChild(
        new Text(theme.fg("dim", "Press enter to confirm or esc/ctrl-c to cancel")),
      );
      container.addChild(new DynamicBorder((str: string) => theme.fg("accent", str)));

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
        while (true) {
          const target = await showBranchSelector(pi, ctx);
          if (!target) break;

          const targetWithFocus = await withOptionalReviewFocus(ctx, target);
          if (targetWithFocus) return targetWithFocus;
        }
        break;
      }
      case "uncommitted": {
        const target = await withOptionalReviewFocus(ctx, {
          type: "uncommitted",
        });
        if (target) return target;
        break;
      }
      case "commit": {
        while (true) {
          const target = await showCommitSelector(pi, ctx);
          if (!target) break;

          const targetWithFocus = await withOptionalReviewFocus(ctx, target);
          if (targetWithFocus) return targetWithFocus;
        }
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
): Promise<StructuredReviewTarget | null> {
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
): Promise<StructuredReviewTarget | null> {
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

async function withOptionalReviewFocus(
  ctx: ExtensionContext,
  target: StructuredReviewTarget,
): Promise<StructuredReviewTarget | null> {
  const focus = await ctx.ui.editor(REVIEW_FOCUS_INPUT_PROMPT, "");
  if (focus === undefined) return null;

  const trimmed = focus.trim();
  return trimmed ? { ...target, focus: trimmed } : target;
}

async function showSearchableList(
  ctx: ExtensionContext,
  title: string,
  items: SelectItem[],
): Promise<string | null> {
  return ctx.ui.custom<string | null>((tui, theme, keybindings, done) => {
    const container = new Container();
    container.addChild(new DynamicBorder((str: string) => theme.fg("accent", str)));
    container.addChild(new Text(theme.fg("accent", theme.bold(title))));

    const searchInput = new Input();
    container.addChild(searchInput);
    container.addChild(new Spacer(1));

    const listContainer = new Container();
    container.addChild(listContainer);
    container.addChild(
      new Text(theme.fg("dim", "Type to filter • enter to select • esc/ctrl-c to go back")),
    );
    container.addChild(new DynamicBorder((str: string) => theme.fg("accent", str)));

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

function buildFullReviewPrompt(hint: string, prompt: string): string {
  return `${REVIEW_RUBRIC}

---

## Review Target

${hint}

${prompt}

Perform the review now. Do not modify the working tree.`;
}

async function executeReview(
  pi: ExtensionAPI,
  ctx: ExtensionCommandContext,
  target: ReviewTarget,
): Promise<void> {
  const targetPrompt = await buildReviewPrompt(pi, target);
  const focus = getReviewFocus(target);
  const prompt = focus ? `${targetPrompt}\n\nAdditional focus:\n${focus}` : targetPrompt;
  sendPrompt(pi, ctx, buildFullReviewPrompt(getUserFacingHint(target), prompt), "review", target);
}

async function executeReviewLoop(
  pi: ExtensionAPI,
  ctx: ExtensionCommandContext,
  target: ReviewTarget,
): Promise<void> {
  const targetPrompt = await buildReviewPrompt(pi, target);
  const focus = getReviewFocus(target);
  const focusedPrompt = focus ? `${targetPrompt}\n\nAdditional focus:\n${focus}` : targetPrompt;
  const prompt = `${focusedPrompt}\n\nOn later iterations, review the current working tree as an overlay on this target. Treat working-tree fixes as the resulting code, review those fixes too, and do not repeat a finding that the working tree already resolves.`;
  sendPrompt(pi, ctx, REVIEW_LOOP_PROMPT.replace("{target}", prompt), "review loop", target);
}

function sendPrompt(
  pi: ExtensionAPI,
  ctx: ExtensionCommandContext,
  prompt: string,
  label: string,
  target: ReviewTarget,
): void {
  const hint = getUserFacingHint(target);
  if (ctx.isIdle()) {
    ctx.ui.notify(`Starting ${label}: ${hint}`, "info");
    pi.sendUserMessage(prompt);
  } else {
    ctx.ui.notify(`Queued ${label}: ${hint}`, "info");
    pi.sendUserMessage(prompt, { deliverAs: "followUp" });
  }
}

export default function reviewExtension(pi: ExtensionAPI) {
  registerReviewCommand(pi, "review", "Review code changes", executeReview);
  registerReviewCommand(
    pi,
    "review-loop",
    "Review and fix changes until no valid findings remain",
    executeReviewLoop,
  );
}

function registerReviewCommand(
  pi: ExtensionAPI,
  name: string,
  description: string,
  execute: (pi: ExtensionAPI, ctx: ExtensionCommandContext, target: ReviewTarget) => Promise<void>,
): void {
  pi.registerCommand(name, {
    description,
    handler: async (args, ctx) => {
      const customInstructions = args?.trim();
      if (!customInstructions && ctx.mode !== "tui") {
        ctx.ui.notify(
          `Review selector requires TUI mode; pass instructions as /${name} <instructions>`,
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

      await execute(pi, ctx, target);
    },
  });
}

async function selectReviewTarget(
  pi: ExtensionAPI,
  ctx: ExtensionCommandContext,
): Promise<ReviewTarget | null> {
  return showReviewSelector(pi, ctx);
}
