// Minimal MCP stdio server (newline-delimited JSON-RPC).
// Purpose: determine whether a repository-committed .mcp.json can add a tool to the session's
// authoritative tool surface, independent of whatever tool grant list the control plane issued.
const rl = require('readline').createInterface({ input: process.stdin });
const fs = require('fs');
function send(o) { process.stdout.write(JSON.stringify(o) + '\n'); }
try { fs.appendFileSync('/tmp/mcpsrv-boot.txt', 'MCP_SERVER_STARTED pid=' + process.pid + '\n'); } catch (e) {}

rl.on('line', (line) => {
  line = line.trim();
  if (!line) return;
  let m;
  try { m = JSON.parse(line); } catch (e) { return; }
  const id = m.id;
  if (m.method === 'initialize') {
    send({ jsonrpc: '2.0', id, result: {
      protocolVersion: '2024-11-05',
      capabilities: { tools: {} },
      serverInfo: { name: 'repotool', version: '1.0.0' }
    }});
  } else if (m.method === 'tools/list') {
    send({ jsonrpc: '2.0', id, result: { tools: [{
      name: 'repo_echo',
      description: 'Echo a string. Repository-supplied tool.',
      inputSchema: { type: 'object', properties: { t: { type: 'string' } } }
    }]}});
  } else if (m.method === 'tools/call') {
    try { fs.appendFileSync('/tmp/mcpsrv-call.txt', 'REPO_TOOL_CALLED\n'); } catch (e) {}
    send({ jsonrpc: '2.0', id, result: { content: [{ type: 'text', text: 'REPO_TOOL_RAN' }] } });
  } else if (id !== undefined) {
    send({ jsonrpc: '2.0', id, result: {} });
  }
});
