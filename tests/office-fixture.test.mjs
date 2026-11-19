import assert from 'node:assert/strict';
import {spawn, spawnSync} from 'node:child_process';
import {copyFileSync, existsSync, mkdtempSync, readFileSync, appendFileSync, rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {dirname, join, resolve} from 'node:path';
import {fileURLToPath} from 'node:url';
import test from 'node:test';
import {createInterface} from 'node:readline';

const repo = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const fixture = join(repo, 'tools/office-fixture');
function client(directory = fixture, environment = {}) {
  const child = spawn(process.execPath, [join(directory, 'server.mjs')], {
    windowsHide: true, stdio: ['pipe', 'pipe', 'pipe'], env: {...process.env, ...environment},
  });
  const pending = new Map();
  let next = 0;
  createInterface({input: child.stdout}).on('line', line => {
    const value = JSON.parse(line);
    const entry = pending.get(value.id);
    if (entry) { clearTimeout(entry.timer); pending.delete(value.id); entry.resolve(value); }
  });
  child.stderr.resume();
  child.on('error', error => { for (const e of pending.values()) e.reject(error); });
  return {
    request(method, params = {}) {
      return new Promise((resolve, reject) => {
        const id = ++next;
        const timer = setTimeout(() => { pending.delete(id); reject(new Error('MCP reply timeout')); }, 100000);
        pending.set(id, {resolve, reject, timer});
        child.stdin.write(JSON.stringify({jsonrpc: '2.0', id, method, params}) + '\n');
      });
    },
    async close() {
      for (const e of pending.values()) clearTimeout(e.timer);
      if (child.exitCode !== null) return;
      const exited = new Promise(resolve => child.once('exit', resolve));
      child.stdin.end();
      await exited;
    },
  };
}

test('MCP exposes one fixed tool and rejects extra inputs', async () => {
  const c = client();
  try {
    const init = await c.request('initialize', {protocolVersion: '2024-11-05'});
    assert.equal(init.result.serverInfo.name, 'local-office-fixture');
    const listing = await c.request('tools/list');
    assert.equal(listing.result.tools.length, 1);
    assert.equal(listing.result.tools[0].name, 'run_hidden_office_fixture');
    assert.equal(listing.result.tools[0].inputSchema.additionalProperties, false);
    for (const args of [{command: 'anything'}, {path: 'C:/elsewhere'}, [], null, 'anything']) {
      const reply = await c.request('tools/call', {name: 'run_hidden_office_fixture', arguments: args});
      assert.match(reply.error.message, /fixed no-argument/);
    }
    assert.equal((await c.request('not-a-method')).error.code, -32601);
  } finally { await c.close(); }
});

test('changed probe is refused before execution and cannot be retried', async () => {
  const directory = mkdtempSync(join(tmpdir(), 'multica-office-hash-'));
  let c;
  try {
    copyFileSync(join(fixture, 'server.mjs'), join(directory, 'server.mjs'));
    copyFileSync(join(fixture, 'probe.ps1'), join(directory, 'probe.ps1'));
    appendFileSync(join(directory, 'probe.ps1'), '\n# unreviewed edit\n');
    c = client(directory);
    const first = await c.request('tools/call', {name: 'run_hidden_office_fixture', arguments: {}});
    assert.match(first.error.message, /hash changed/);
    assert.equal(existsSync(join(directory, 'output')), false);
    const second = await c.request('tools/call', {name: 'run_hidden_office_fixture', arguments: {}});
    assert.match(second.error.message, /one attempt/);
  } finally {
    if (c) await c.close();
    // mkdtemp created this exact directory under tmpdir; never remove a computed parent.
    assert.equal(dirname(directory), resolve(tmpdir()));
    rmSync(directory, {recursive: true});
  }
});

test('relative executable setting is refused', {skip: process.platform !== 'win32'}, async () => {
  const c = client(fixture, {MULTICA_OFFICE_PWSH: 'untrusted-relative.exe'});
  try {
    const reply = await c.request('tools/call', {name: 'run_hidden_office_fixture', arguments: {}});
    assert.match(reply.error.message, /absolute owner-configured/);
  } finally { await c.close(); }
});

test('real hidden Office MCP operation and independent saved-file checks', {
  skip: process.env.MULTICA_TEST_OFFICE !== '1' || process.platform !== 'win32', timeout: 120000,
}, async () => {
  const c = client();
  try {
    const reply = await c.request('tools/call', {name: 'run_hidden_office_fixture', arguments: {}});
    assert.equal(reply.error, undefined);
    assert.equal(reply.result.isError, false, JSON.stringify(reply.result));
    const receipt = JSON.parse(reply.result.content[0].text);
    const records = JSON.parse(receipt.stdout.trim().replace(/^\uFEFF/, ''));
    assert.equal(records.length, 2);
    assert.ok(records.every(r => r.pass && !r.visible && !r.test_was_foreground));
    const resultFile = join(dirname(records[0].file), 'result.json');
    assert.ok(readFileSync(resultFile).length > 0);
    const powershell = process.env.MULTICA_OFFICE_PWSH || join(process.env.SystemRoot, 'System32/WindowsPowerShell/v1.0/powershell.exe');
    const verify = spawnSync(powershell, ['-NoProfile', '-NonInteractive', '-File', join(repo, 'tests/office-artifacts.ps1'), '-ResultFile', resultFile], {
      encoding: 'utf8', windowsHide: true, timeout: 20000,
    });
    assert.equal(verify.status, 0, verify.stdout + verify.stderr);
    assert.equal(JSON.parse(verify.stdout.trim()).verified, true);
    const second = await c.request('tools/call', {name: 'run_hidden_office_fixture', arguments: {}});
    assert.match(second.error.message, /one attempt/);
  } finally { await c.close(); }
});
