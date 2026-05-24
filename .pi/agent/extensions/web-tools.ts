/**
 * Web Tools for pi
 *
 *   websearch  — Exa MCP semantic search
 *   webfetch   — Fetch clean content from any URL via Exa MCP extraction
 *
 * Uses Exa MCP (https://mcp.exa.ai/mcp) — no API key required.
 * Free tier: 150 calls/day, 3 QPS.
 */

import {
  truncateHead,
  DEFAULT_MAX_BYTES,
  DEFAULT_MAX_LINES,
  type ExtensionAPI,
} from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { Text } from "@earendil-works/pi-tui";

// ─── MCP Client ────────────────────────────────────────────────────────────────

const MCP = "https://mcp.exa.ai/mcp";
const TIMEOUT = 30000;
const SEARCH_MAX_BYTES = 14000;
const SEARCH_MAX_LINES = 180;
const FETCH_DEFAULT_CHARS = 8000;
const FETCH_MAX_CHARS = 20000;
const FETCH_RESPONSE_OVERHEAD = 1500;

/** Call an Exa MCP tool via JSON-RPC. Returns the text from the first content item. */
async function callMcp(name: string, args: object, signal?: AbortSignal): Promise<string> {
  const res = await fetch(MCP, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json, text/event-stream",
    },
    body: JSON.stringify({
      jsonrpc: "2.0",
      id: 1,
      method: "tools/call",
      params: { name, arguments: args },
    }),
    signal: signal
      ? AbortSignal.any([signal, AbortSignal.timeout(TIMEOUT)])
      : AbortSignal.timeout(TIMEOUT),
  });
  if (!res.ok)
    throw new Error(`Exa MCP ${res.status}: ${(await res.text().catch(() => "")).slice(0, 300)}`);

  const raw = await res.text();
  // Try SSE data: lines first, then fallback to plain JSON
  for (const line of raw.split("\n")) {
    if (!line.startsWith("data:")) continue;
    let p: any;
    try {
      p = JSON.parse(line.slice(5).trim()) as any;
    } catch {
      continue;
    }
    const r = p?.result;
    if (r) {
      if (r.isError)
        throw new Error(r.content?.find((c: any) => c.type === "text")?.text || "MCP error");
      const t = r.content?.find((c: any) => c.type === "text" && typeof c.text === "string")?.text;
      if (t) return t;
    }
    if (p?.error) throw new Error(`MCP error: ${p.error.message}`);
  }
  // Fallback: try as plain JSON
  try {
    const p = JSON.parse(raw) as any;
    const r = p?.result;
    if (r) {
      if (r.isError)
        throw new Error(r.content?.find((c: any) => c.type === "text")?.text || "MCP error");
      const t = r.content?.find((c: any) => c.type === "text" && typeof c.text === "string")?.text;
      if (t) return t;
    }
    if (p?.error) throw new Error(`MCP error: ${p.error.message}`);
  } catch (e: any) {
    if (e.message?.startsWith("MCP error") || e.message?.startsWith("Exa MCP")) throw e;
  }
  throw new Error("Empty MCP response");
}

// ─── Rendering ──────────────────────────────────────────────────────────────────

function firstText(result: any): string {
  const text = result?.content?.find(
    (c: any) => c.type === "text" && typeof c.text === "string",
  )?.text;
  return typeof text === "string" ? text.trim() : "";
}

function renderStatus(
  action: "search" | "fetch",
  result: any,
  theme: any,
  context?: { isError?: boolean },
) {
  if (context?.isError) {
    const message = firstText(result).split("\n")[0];
    const suffix = message ? `: ${message.slice(0, 100)}` : "";
    return new Text(theme.fg("error", `✗ ${action} failed${suffix}`), 0, 0);
  }
  return new Text(theme.fg("success", `✓ ${action} complete`), 0, 0);
}

// ─── Extension ──────────────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "websearch",
    label: "Web Search",
    description:
      "Search the web using Exa for current info when local files are insufficient. Returns key excerpts; fetch relevant URLs before relying on claims.",
    promptSnippet: "Find web results",
    parameters: Type.Object({
      query: Type.String({ description: "Natural language search query" }),
      numResults: Type.Optional(
        Type.Integer({ description: "Results (1-8, default 5)", minimum: 1, maximum: 8 }),
      ),
    }),

    async execute(_id, params, signal) {
      const numResults = Math.max(1, Math.min(8, params.numResults ?? 5));
      const query = params.query.trim();
      if (!query) throw new Error("Query cannot be empty.");

      const raw = await callMcp("web_search_exa", { query, numResults }, signal);
      const formatted = raw.trim();
      if (!formatted) return { content: [{ type: "text", text: "No results found." }] };

      const truncated = truncateHead(formatted, {
        maxLines: Math.min(DEFAULT_MAX_LINES, SEARCH_MAX_LINES),
        maxBytes: Math.min(DEFAULT_MAX_BYTES, SEARCH_MAX_BYTES),
      });
      let text = truncated.content;
      if (truncated.truncated)
        text += `\n\n[Output truncated. ${truncated.outputLines} of ${truncated.totalLines} lines shown.]`;
      return { content: [{ type: "text", text }] };
    },

    renderCall(args, theme) {
      const q = String((args as any).query ?? "");
      const preview = q.length > 50 ? `${q.slice(0, 47)}...` : q;
      const text = `${theme.fg("toolTitle", theme.bold("search"))} ${theme.fg("accent", preview || "(empty)")}`;
      return new Text(text, 0, 0);
    },

    renderResult(result, _options, theme, context) {
      return renderStatus("search", result, theme, context);
    },
  });

  pi.registerTool({
    name: "webfetch",
    label: "Web Fetch",
    description:
      "Fetch clean content from known URLs via Exa extraction. Handles JS sites, layouts, and paywalled content.",
    promptSnippet: "Extract URL content",
    parameters: Type.Object({
      url: Type.Optional(Type.String({ description: "Single URL to fetch" })),
      urls: Type.Optional(
        Type.Array(Type.String(), {
          description: "Multiple URLs (1-5). Mutually exclusive with url.",
          minItems: 1,
          maxItems: 5,
        }),
      ),
      maxChars: Type.Optional(
        Type.Integer({
          description: "Max characters per URL (default 8000)",
          minimum: 1000,
          maximum: FETCH_MAX_CHARS,
        }),
      ),
    }),

    async execute(_id, params, signal) {
      if (params.url && params.urls) throw new Error("Use either 'url' or 'urls', not both.");

      const inputUrls = params.urls ?? (params.url ? [params.url] : []);
      const urlList = [...new Set(inputUrls.map((u) => u.trim()).filter(Boolean))];
      if (urlList.length === 0) throw new Error("Provide 'url' or 'urls'.");
      if (urlList.length > 5) throw new Error("Max 5 URLs per call.");
      for (const url of urlList) {
        const parsed = new URL(url);
        if (parsed.protocol !== "http:" && parsed.protocol !== "https:")
          throw new Error(`Only http(s) URLs are supported: ${url}`);
      }

      const maxChars = Math.max(
        1000,
        Math.min(FETCH_MAX_CHARS, params.maxChars ?? FETCH_DEFAULT_CHARS),
      );
      const raw = await callMcp(
        "web_fetch_exa",
        { urls: urlList, maxCharacters: maxChars },
        signal,
      );
      const formatted = raw.trim();
      if (!formatted) return { content: [{ type: "text", text: "No content retrieved." }] };

      const truncated = truncateHead(formatted, {
        maxLines: DEFAULT_MAX_LINES,
        maxBytes: Math.min(
          DEFAULT_MAX_BYTES,
          urlList.length * (maxChars + FETCH_RESPONSE_OVERHEAD),
        ),
      });
      let text = truncated.content;
      if (truncated.truncated)
        text += `\n\n[Output truncated. ${truncated.outputLines} of ${truncated.totalLines} lines shown.]`;
      return { content: [{ type: "text", text }] };
    },

    renderCall(args, theme) {
      const urls = (args as any).urls ?? ((args as any).url ? [(args as any).url] : []);
      const preview = urls.length <= 1 ? String(urls[0] ?? "(no URL)") : `${urls.length} URLs`;
      const short = preview.length > 60 ? `${preview.slice(0, 57)}...` : preview;
      const text = `${theme.fg("toolTitle", theme.bold("fetch"))} ${theme.fg("accent", short)}`;
      return new Text(text, 0, 0);
    },

    renderResult(result, _options, theme, context) {
      return renderStatus("fetch", result, theme, context);
    },
  });
}
