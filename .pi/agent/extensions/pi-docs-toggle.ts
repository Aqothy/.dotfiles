import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";

let docsEnabled = false;
let lastPrompt = "";

function stripPiDocs(prompt: string): string {
  const lines = prompt.split("\n");
  const start = lines.findIndex((line) => line.trim().startsWith("Pi documentation"));
  if (start === -1) return prompt;

  let end = start + 1;
  while (end < lines.length && lines[end]!.trim().startsWith("- ")) end++;
  if (lines[end] === "") end++;

  return [...lines.slice(0, start), ...lines.slice(end)].join("\n").replace(/\n{3,}/g, "\n\n");
}

async function showPrompt(ctx: ExtensionCommandContext) {
  if (!ctx.hasUI) return;

  const prompt =
    lastPrompt || (docsEnabled ? ctx.getSystemPrompt() : stripPiDocs(ctx.getSystemPrompt()));

  await ctx.ui.editor("System prompt", prompt);
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("pi-docs", {
    description: "Toggle Pi documentation instructions in the system prompt",
    handler: async (args, ctx) => {
      const arg = args.trim().toLowerCase();

      if (arg === "show") {
        await showPrompt(ctx);
        return;
      }

      if (arg === "on") docsEnabled = true;
      else if (arg === "off") docsEnabled = false;
      else if (arg === "") docsEnabled = !docsEnabled;
      else {
        ctx.ui.notify("Usage: /pi-docs [on|off|show]", "error");
        return;
      }

      lastPrompt = docsEnabled ? ctx.getSystemPrompt() : stripPiDocs(ctx.getSystemPrompt());
      ctx.ui.notify(`Pi docs are ${docsEnabled ? "on" : "off"}.`, "info");
    },
  });

  pi.on("before_agent_start", async (event) => {
    const prompt = docsEnabled ? event.systemPrompt : stripPiDocs(event.systemPrompt);
    lastPrompt = prompt;
    return prompt === event.systemPrompt ? undefined : { systemPrompt: prompt };
  });
}
