import assert from "node:assert/strict";
import { once } from "node:events";
import { test } from "node:test";
import { createBridge } from "../Resources/responses-bridge.mjs";

function chatStream(chunks) {
  const body = chunks.map((chunk) => `data: ${JSON.stringify(chunk)}\r\n\r\n`).join("");
  return new Response(body + "data: [DONE]\r\n\r\n", {
    headers: { "Content-Type": "text/event-stream" },
  });
}

async function openBridge(t, provider, send) {
  const server = createBridge({ provider, path: "/test/v1", send });
  server.listen(0, "127.0.0.1");
  await once(server, "listening");
  t.after(() => { server.close(); server.closeAllConnections(); });
  return `http://127.0.0.1:${server.address().port}/test/v1/responses`;
}

const post = (url, data, key = "fixture-key") => fetch(url, {
  method: "POST",
  headers: { Authorization: `Bearer ${key}`, "Content-Type": "application/json" },
  body: JSON.stringify(data),
});

test("Gemini streams text and retains function arguments and thought signatures across requests", async (t) => {
  const upstream = [];
  const url = await openBridge(t, "switcher_gemini_api", (endpoint, opts) => {
    assert.equal(endpoint, "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions");
    assert.equal(opts.redirect, "error");
    assert.equal(opts.headers.Authorization, "Bearer fixture-key");
    upstream.push(JSON.parse(opts.body));
    if (upstream.length === 1) {
      return chatStream([
        { choices: [{ delta: { content: "Checking" } }] },
        { choices: [{ delta: { content: " now." } }] },
        { choices: [{ delta: { tool_calls: [{
          id: "call_real", index: 0, function: { name: "lookup", arguments: '{"city":' },
          extra_content: { google: { thought_signature: "opaque-signature" } },
        }] } }] },
        { choices: [{ delta: { tool_calls: [{ index: 0, function: { arguments: '"London"}' } }] },
                      finish_reason: "tool_calls" }] },
        { choices: [], usage: { prompt_tokens: 30, completion_tokens: 12, total_tokens: 42 } },
      ]);
    }
    return chatStream([{ choices: [{ delta: { content: "Sunny." }, finish_reason: "stop" }] }]);
  });
  const question = { role: "user", content: "Check the weather." };
  const first = await post(url, {
    model: "gemini-3.8-flash", stream: true, input: [question], reasoning: { effort: "medium" },
    tools: [{ type: "function", name: "lookup", parameters: { type: "object", properties: { city: { type: "string" } } } }],
  });
  assert.equal(first.status, 200);
  const events = (await first.text()).split("\n").filter((line) => line.startsWith("data: "))
    .map((line) => JSON.parse(line.slice(6)));
  assert.equal(events.filter((event) => event.type === "response.output_text.delta").map((event) => event.delta).join(""), "Checking now.");
  const response = events.at(-1).response;
  const tool = response.output.find((item) => item.type === "function_call");
  assert.equal(tool.arguments, '{"city":"London"}');
  assert.equal(tool.call_id, "call_real");
  assert.equal(response.usage.total_tokens, 42);
  assert.equal(upstream[0].reasoning_effort, "medium");
  assert.equal(upstream[0].tools[0].function.name, "lookup");

  const followup = await post(url, {
    model: "gemini-3.8-flash", input: [question, ...response.output,
      { type: "function_call_output", call_id: tool.call_id, output: "clear" }],
  });
  assert.equal((await followup.json()).output[0].content[0].text, "Sunny.");
  assert.equal(upstream[1].messages[1].tool_calls[0].extra_content.google.thought_signature, "opaque-signature");
  assert.deepEqual(upstream[1].messages[2], { role: "tool", tool_call_id: "call_real", content: "clear" });
});

test("Claude forwards images, translates free-form tool calls, and returns clean upstream errors", async (t) => {
  const url = await openBridge(t, "switcher_claude_api", (endpoint, opts) => {
    assert.equal(endpoint, "https://api.anthropic.com/v1/chat/completions");
    const request = JSON.parse(opts.body);
    if (request.messages[0].content === "test-error") {
      return Response.json({ error: { message: "Invalid fixture-key" } }, { status: 401 });
    }
    assert.equal(request.messages[0].content[1].image_url.url, "data:image/png;base64,AA==");
    assert.equal(request.tools[0].function.parameters.properties.input.type, "string");
    return chatStream([{ choices: [{ delta: { tool_calls: [{
      id: "call_patch", index: 0, function: { name: "apply_patch", arguments: '{"input":"patch content"}' },
    }] }, finish_reason: "tool_calls" }] }]);
  });
  const output = await post(url, {
    model: "claude-sonnet-5-5",
    input: [{ role: "user", content: [{ type: "input_text", text: "Screenshot" },
      { type: "input_image", image_url: "data:image/png;base64,AA==" }] }],
    tools: [{ type: "custom", name: "apply_patch" }],
  });
  const tool = (await output.json()).output[0];
  assert.equal(tool.type, "custom_tool_call");
  assert.equal(tool.input, "patch content");
  const error = await post(url, { model: "claude-sonnet-5-5", input: "test-error" });
  assert.equal(error.status, 401);
  assert.equal((await error.json()).error.message, "Invalid [redacted]");
  assert.equal((await fetch(url)).status, 404);
});
