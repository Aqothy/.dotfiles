import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { copyToClipboard, TreeSelectorComponent } from "@earendil-works/pi-coding-agent";
import { getKeybindings } from "@earendil-works/pi-tui";

const COPY_KEYBINDING = "tui.editor.yank"; // Ctrl+Y by default.
const PATCHED = Symbol.for("tree-copy.patched");
const ORIGINAL_HANDLE_INPUT = Symbol.for("tree-copy.originalHandleInput");

let ctx: ExtensionContext | undefined;

function messageText(message: unknown): string | undefined {
  if (!message || typeof message !== "object") return undefined;
  const content = (message as { content?: unknown }).content;

  if (typeof content === "string") return content.trim() || undefined;
  if (!Array.isArray(content)) return undefined;

  const text = content
    .filter(
      (block): block is { type: "text"; text: string } =>
        block !== null &&
        typeof block === "object" &&
        (block as { type?: unknown }).type === "text" &&
        typeof (block as { text?: unknown }).text === "string",
    )
    .map((block) => block.text)
    .join("")
    .trim();

  return text || undefined;
}

async function copySelectedTreeMessage(treeSelector: TreeSelectorComponent) {
  const treeList = treeSelector.getTreeList();
  const selected = treeList.getSelectedNode();
  const entry = selected?.entry;

  const text = entry?.type === "message" ? messageText(entry.message) : undefined;
  if (!text) {
    ctx?.ui.notify("Selected tree entry has no message text to copy", "warning");
    return;
  }

  await copyToClipboard(text);
  ctx?.ui.notify("Copied selected tree message to clipboard", "info");
}

function patchTreeSelector() {
  const proto = TreeSelectorComponent.prototype as typeof TreeSelectorComponent.prototype & {
    [PATCHED]?: boolean;
    [ORIGINAL_HANDLE_INPUT]?: TreeSelectorComponent["handleInput"];
  };

  if (proto[PATCHED]) return;
  proto[PATCHED] = true;
  proto[ORIGINAL_HANDLE_INPUT] = proto.handleInput;

  // /tree has no extension hook for per-picker keymaps, so patch only its input handler.
  proto.handleInput = function (this: TreeSelectorComponent, keyData: string) {
    const editingLabel = Boolean((this as unknown as { labelInput?: unknown }).labelInput);
    if (!editingLabel && getKeybindings().matches(keyData, COPY_KEYBINDING)) {
      void copySelectedTreeMessage(this).catch((error) => {
        const message = error instanceof Error ? error.message : String(error);
        ctx?.ui.notify(`Failed to copy tree message: ${message}`, "error");
      });
      return;
    }

    return proto[ORIGINAL_HANDLE_INPUT]!.call(this, keyData);
  };
}

function unpatchTreeSelector() {
  const proto = TreeSelectorComponent.prototype as typeof TreeSelectorComponent.prototype & {
    [PATCHED]?: boolean;
    [ORIGINAL_HANDLE_INPUT]?: TreeSelectorComponent["handleInput"];
  };

  if (!proto[PATCHED]) return;
  if (proto[ORIGINAL_HANDLE_INPUT]) proto.handleInput = proto[ORIGINAL_HANDLE_INPUT];
  proto[PATCHED] = false;
  proto[ORIGINAL_HANDLE_INPUT] = undefined;
}

export default function (pi: ExtensionAPI) {
  patchTreeSelector();

  pi.on("session_start", (_event, context) => {
    ctx = context;
  });

  pi.on("session_shutdown", () => {
    ctx = undefined;
    unpatchTreeSelector();
  });
}
