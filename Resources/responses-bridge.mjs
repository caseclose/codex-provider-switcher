import { spawn } from "node:child_process";
import { randomBytes, randomUUID } from "node:crypto";
import { createServer } from "node:http";
import { once } from "node:events";
import { createInterface } from "node:readline";
import { Readable } from "node:stream";
import { pathToFileURL } from "node:url";

const endpoints = {
  switcher_gemini_api: "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions",
  switcher_claude_api: "https://api.anthropic.com/v1/chat/completions",
};
const signaturePrefix = "switcher-gemini-v1:";
const newID = (prefix) => `${prefix}_${randomUUID().replaceAll("-", "")}`;

function messageContent(content) {
  if (typeof content === "string") return content;
  const parts = (content ?? []).map((part) => {
    if (part.type === "input_image") {
      return { type: "image_url", image_url: { url: part.image_url } };
    }
    if (["input_text", "output_text", "text"].includes(part.type)) {
      return { type: "text", text: part.text };
    }
    throw new Error(`Unsupported message content: ${part.type}`);
  });
  return parts.every((part) => part.type === "text") ? parts.map((part) => part.text).join("\n") : parts;
}

function geminiSignatures(items) {
  const signatures = new Map();
  for (const item of items) {
    if (item.type !== "reasoning" || !item.encrypted_content?.startsWith(signaturePrefix)) continue;
    try {
      const payload = Buffer.from(item.encrypted_content.slice(signaturePrefix.length), "base64url");
      for (const [id, signature] of JSON.parse(payload)) {
        if (typeof id === "string" && typeof signature === "string") signatures.set(id, signature);
      }
    } catch {
      throw new Error("Invalid Gemini tool history. Start a new local session.");
    }
  }
  return signatures;
}

function chatRequest(input, gemini) {
  if (input.previous_response_id || input.conversation) {
    throw new Error("This provider requires the full conversation in each request.");
  }
  const items = typeof input.input === "string" ? [{ role: "user", content: input.input }] : input.input;
  if (typeof input.model !== "string" || !Array.isArray(items)) {
    throw new Error("A model and conversation are required.");
  }

  const signatures = gemini ? geminiSignatures(items) : new Map();
  const messages = input.instructions ? [{ role: "system", content: input.instructions }] : [];
  let assistant;
  const attachments = [];
  for (const item of items) {
    if (item.type === "reasoning") continue;
    if (!["function_call_output", "custom_tool_call_output"].includes(item.type) && attachments.length) {
      messages.push({ role: "user", content: attachments.splice(0) });
    }
    if (item.type === "function_call" || item.type === "custom_tool_call") {
      if (!assistant) {
        assistant = { role: "assistant", content: null };
        messages.push(assistant);
      }
      const args = item.type === "function_call" ? item.arguments : JSON.stringify({ input: item.input });
      const call = { id: item.call_id, type: "function", function: { name: item.name, arguments: args } };
      if (signatures.has(call.id)) {
        call.extra_content = { google: { thought_signature: signatures.get(call.id) } };
      }
      (assistant.tool_calls ??= []).push(call);
    } else if (item.type === "function_call_output" || item.type === "custom_tool_call_output") {
      const content = messageContent(item.output);
      const text = typeof content === "string" ? content : content.filter((part) => part.type === "text").map((part) => part.text).join("\n");
      if (Array.isArray(content)) attachments.push(...content.filter((part) => part.type === "image_url"));
      messages.push({ role: "tool", tool_call_id: item.call_id, content: text || "Tool output attached." });
      assistant = undefined;
    } else if (item.type === "message" || (!item.type && item.role)) {
      const role = item.role === "developer" ? "system" : item.role;
      const message = { role, content: messageContent(item.content) };
      messages.push(message);
      assistant = role === "assistant" ? message : undefined;
    } else {
      throw new Error(`Unsupported conversation item: ${item.type}`);
    }
  }
  if (attachments.length) messages.push({ role: "user", content: attachments });

  const custom = new Set();
  const tools = [];
  for (const tool of input.tools ?? []) {
    if (tool.type === "function") {
      const { name, description, parameters } = tool;
      tools.push({ type: "function", function: { name, description, parameters } });
    } else if (tool.type === "custom") {
      custom.add(tool.name);
      tools.push({
        type: "function",
        function: {
          name: tool.name, description: tool.description,
          parameters: { type: "object", properties: { input: { type: "string" } }, required: ["input"] },
        },
      });
    }
  }
  const request = {
    model: input.model, messages, stream: true,
    stream_options: { include_usage: true },
    max_completion_tokens: input.max_output_tokens ?? 32768,
  };
  if (tools.length) {
    request.tools = tools;
    request.tool_choice = "auto";
    if (typeof input.parallel_tool_calls === "boolean") request.parallel_tool_calls = input.parallel_tool_calls;
  }
  if (gemini && ["low", "medium", "high"].includes(input.reasoning?.effort)) {
    request.reasoning_effort = input.reasoning.effort;
  }
  const format = input.text?.format;
  if (format?.type === "json_schema") {
    const { name, description, schema, strict } = format;
    request.response_format = { type: "json_schema", json_schema: { name, description, schema, strict } };
  }
  return { request, custom };
}

async function* streamData(body) {
  const lines = createInterface({ input: Readable.fromWeb(body), crlfDelay: Infinity });
  let data = [];
  for await (const line of lines) {
    if (line.startsWith("data:")) data.push(line.slice(5).trimStart());
    if (!line && data.length) {
      yield data.join("\n");
      data = [];
    }
  }
  if (data.length) yield data.join("\n");
}

async function translateStream(upstream, input, custom, output) {
  const response = {
    id: newID("resp"), object: "response", created_at: Math.floor(Date.now() / 1000),
    model: input.model, status: "in_progress", output: [],
  };
  let sequence = 0;
  const emit = (type, detail) => output.write(`event: ${type}\ndata: ${JSON.stringify({
    type, sequence_number: sequence++, ...detail,
  })}\n\n`);
  const stream = input.stream === true;
  const send = stream ? emit : () => {};
  if (stream) {
    output.writeHead(200, { "Content-Type": "text/event-stream; charset=utf-8", "Cache-Control": "no-store" });
  }
  send("response.created", { response });

  let message;
  let text;
  let finishReason;
  let usage;
  const calls = new Map();
  for await (const data of streamData(upstream.body)) {
    if (data === "[DONE]") break;
    const chunk = JSON.parse(data);
    if (chunk.error) throw new Error(chunk.error.message || "Upstream stream error.");
    if (chunk.usage) usage = chunk.usage;
    const choice = chunk.choices?.[0];
    if (!choice) continue;
    finishReason = choice.finish_reason ?? finishReason;
    const delta = choice.delta ?? choice.message ?? {};
    if (typeof delta.content === "string" && delta.content) {
      if (!message) {
        message = { id: newID("msg"), type: "message", role: "assistant", status: "in_progress", content: [] };
        text = { type: "output_text", text: "", annotations: [] };
        send("response.output_item.added", { output_index: 0, item: message });
        message.content.push(text);
        send("response.content_part.added", { item_id: message.id, output_index: 0, content_index: 0, part: text });
      }
      text.text += delta.content;
      send("response.output_text.delta", { item_id: message.id, output_index: 0, content_index: 0, delta: delta.content });
    }
    for (const tool of delta.tool_calls ?? []) {
      const index = tool.index ?? 0;
      const call = calls.get(index) ?? { name: "", arguments: "" };
      call.id = tool.id ?? call.id;
      call.name += tool.function?.name ?? "";
      call.arguments += tool.function?.arguments ?? "";
      call.signature = tool.extra_content?.google?.thought_signature ?? call.signature;
      calls.set(index, call);
    }
  }
  if (!finishReason) throw new Error("The upstream stream ended before a complete response.");
  const incomplete = ["length", "content_filter"].includes(finishReason);
  if (message) {
    message.status = incomplete ? "incomplete" : "completed";
    send("response.output_text.done", { item_id: message.id, output_index: 0, content_index: 0, text: text.text });
    send("response.content_part.done", { item_id: message.id, output_index: 0, content_index: 0, part: text });
    send("response.output_item.done", { output_index: 0, item: message });
    response.output.push(message);
  }

  const addItem = (item) => {
    const output_index = response.output.length;
    send("response.output_item.added", { output_index, item });
    send("response.output_item.done", { output_index, item });
    response.output.push(item);
  };
  if (!incomplete) {
    const signatures = [];
    for (const call of calls.values()) {
      call.id ??= newID("call");
      if (typeof call.signature === "string") signatures.push([call.id, call.signature]);
    }
    if (signatures.length) {
      const encrypted_content = signaturePrefix + Buffer.from(JSON.stringify(signatures)).toString("base64url");
      addItem({ id: newID("rs"), type: "reasoning", summary: [], encrypted_content });
    }
    for (const call of calls.values()) {
      const common = { id: newID("fc"), call_id: call.id, name: call.name, status: "completed" };
      if (custom.has(call.name)) {
        const args = JSON.parse(call.arguments);
        if (typeof args.input !== "string") throw new Error("Invalid free-form tool input.");
        addItem({ ...common, type: "custom_tool_call", input: args.input });
      } else {
        addItem({ ...common, type: "function_call", arguments: call.arguments });
      }
    }
  }

  response.status = incomplete ? "incomplete" : "completed";
  response.incomplete_details = incomplete ? { reason: finishReason === "length" ? "max_output_tokens" : finishReason } : null;
  if (usage) {
    response.usage = {
      input_tokens: usage.prompt_tokens ?? 0,
      input_tokens_details: { cached_tokens: usage.prompt_tokens_details?.cached_tokens ?? 0 },
      output_tokens: usage.completion_tokens ?? 0,
      output_tokens_details: { reasoning_tokens: usage.completion_tokens_details?.reasoning_tokens ?? 0 },
      total_tokens: usage.total_tokens ?? (usage.prompt_tokens ?? 0) + (usage.completion_tokens ?? 0),
    };
  }
  send(incomplete ? "response.incomplete" : "response.completed", { response });
  if (stream) output.end();
  else sendJSON(output, 200, response);
}

function sendJSON(response, status, data) {
  response.writeHead(status, { "Content-Type": "application/json; charset=utf-8", "Cache-Control": "no-store" });
  response.end(JSON.stringify(data));
}

async function requestJSON(request) {
  const chunks = [];
  let size = 0;
  for await (const chunk of request) {
    size += chunk.length;
    if (size > 64 * 1024 * 1024) throw new Error("Request exceeds the bridge's 64 MiB limit.");
    chunks.push(chunk);
  }
  return JSON.parse(Buffer.concat(chunks));
}

export function createBridge({ provider, path, send = fetch }) {
  const endpoint = endpoints[provider];
  if (!endpoint) throw new Error("Unknown bridge provider.");
  return createServer(async (request, response) => {
    if (request.method !== "POST" || request.url !== `${path}/responses`) {
      return sendJSON(response, 404, { error: { message: "Unknown local Responses endpoint." } });
    }
    const key = request.headers.authorization?.match(/^Bearer (\S+)$/i)?.[1];
    if (!key) return sendJSON(response, 401, { error: { message: "Provider API key is missing." } });
    const abort = new AbortController();
    response.once("close", () => abort.abort());
    const safe = (message) => String(message).replaceAll(key, "[redacted]");
    let input;
    let chat;
    try {
      input = await requestJSON(request);
      chat = chatRequest(input, provider === "switcher_gemini_api");
    } catch (error) {
      return sendJSON(response, 400, { error: { message: safe(error.message) } });
    }
    try {
      const upstream = await send(endpoint, {
        method: "POST",
        redirect: "error",
        headers: { Authorization: `Bearer ${key}`, "Content-Type": "application/json", Accept: "text/event-stream" },
        body: JSON.stringify(chat.request),
        signal: AbortSignal.any([abort.signal, AbortSignal.timeout(900_000)]),
      });
      if (!upstream.ok) {
        const data = await upstream.json().catch(() => ({}));
        const retryAfter = upstream.headers.get("retry-after");
        if (retryAfter) response.setHeader("Retry-After", retryAfter);
        return sendJSON(response, upstream.status, {
          error: { message: safe(data.error?.message ?? `Upstream returned HTTP ${upstream.status}.`) },
        });
      }
      if (!upstream.headers.get("content-type")?.includes("text/event-stream")) {
        throw new Error("The upstream API returned an unexpected stream format.");
      }
      await translateStream(upstream, input, chat.custom, response);
    } catch (error) {
      if (response.destroyed) return;
      const message = safe(error.message);
      if (response.headersSent) {
        response.end(`event: error\ndata: ${JSON.stringify({ type: "error", code: "upstream_error", message })}\n\n`);
      } else {
        sendJSON(response, 502, { error: { message } });
      }
    }
  });
}

async function run(provider, codex, config, args) {
  const path = `/${randomBytes(24).toString("hex")}/v1`;
  const server = createBridge({ provider, path });
  server.listen({ host: "127.0.0.1", port: 0 });
  await once(server, "listening");
  const address = `http://127.0.0.1:${server.address().port}${path}`;
  const child = spawn(codex, [...config, "-c", `model_providers.${provider}.base_url="${address}"`, ...args], { stdio: "inherit" });
  const signals = ["SIGHUP", "SIGINT", "SIGTERM"];
  const forward = (signal) => child.kill(signal);
  for (const signal of signals) process.on(signal, forward);
  try {
    const [code] = await once(child, "exit");
    process.exitCode = code ?? 1;
  } finally {
    for (const signal of signals) process.off(signal, forward);
    server.close();
    server.closeAllConnections();
  }
}

if (import.meta.url === pathToFileURL(process.argv[1] ?? "").href) {
  const [, , provider, codex, configLength, ...args] = process.argv;
  const split = Number(configLength);
  run(provider, codex, args.slice(0, split), args.slice(split)).catch((error) => {
    console.error("Could not start the local Responses bridge:", error.message);
    process.exitCode = 1;
  });
}
