// One fixed host operation. MCP callers cannot supply commands or paths.
import {createInterface} from 'node:readline';
import {spawn} from 'node:child_process';
import {createHash, randomUUID} from 'node:crypto';
import {appendFileSync, lstatSync, mkdirSync, readFileSync} from 'node:fs';
import {dirname, isAbsolute, join} from 'node:path';
import {fileURLToPath} from 'node:url';

const root = dirname(fileURLToPath(import.meta.url));
const output = join(root, 'output');
// Hash canonical LF text so a CRLF checkout does not change the reviewed script.
const expectedHash = 'c026540ae31426236564b23012938139fe5547f50602f84d880ee1c2fafa014d';
let used = false;
const tool = {
  name: 'run_hidden_office_fixture',
  description: 'Run the fixed hidden Excel/Word proof once. Creates new disposable documents only under this package\'s output folder and refuses an existing Word process. No desktop input, arbitrary commands, paths or user documents.',
  inputSchema: {type: 'object', properties: {}, additionalProperties: false},
  annotations: {readOnlyHint: false, destructiveHint: false, idempotentHint: false, openWorldHint: false},
};

function send(value) { process.stdout.write(JSON.stringify(value) + '\n'); }
async function execute() {
  if (used) throw new Error('Only one attempt is permitted per server process');
  used = true;
  const script = join(root, 'probe.ps1');
  const text = readFileSync(script, 'utf8').replace(/\r\n/g, '\n');
  if (createHash('sha256').update(text).digest('hex') !== expectedHash) {
    throw new Error('Reviewed script hash changed; refusing execution');
  }
  if (process.platform !== 'win32') throw new Error('This fixture requires Windows');
  const powershell = process.env.MULTICA_OFFICE_PWSH || '';
  if (!isAbsolute(powershell)) throw new Error('PowerShell executable must be an absolute owner-configured path');
  mkdirSync(output, {recursive: true});
  if (lstatSync(output).isSymbolicLink()) throw new Error('Output root must not be a link or junction');
  const receipt = {id: randomUUID(), started_at: new Date().toISOString(), script_sha256: expectedHash};
  const result = await new Promise((resolve, reject) => {
    const env = {};
    for (const key of ['SystemRoot', 'WINDIR', 'ComSpec', 'PATH', 'PATHEXT', 'TEMP', 'TMP', 'APPDATA', 'LOCALAPPDATA', 'USERPROFILE', 'HOMEDRIVE', 'HOMEPATH', 'USERNAME', 'USERDOMAIN', 'ProgramFiles', 'ProgramFiles(x86)', 'CommonProgramFiles', 'CommonProgramFiles(x86)', 'ProgramData']) {
      if (process.env[key]) env[key] = process.env[key];
    }
    const child = spawn(powershell, ['-NoProfile', '-NonInteractive', '-File', script], {
      windowsHide: true, env, cwd: root, stdio: ['ignore', 'pipe', 'pipe'],
    });
    let stdout = '', stderr = '', exceeded = false;
    const timer = setTimeout(() => {
      child.kill();
      reject(new Error('Fixed Office probe exceeded 90 seconds'));
    }, 90000);
    child.stdout.on('data', data => {
      stdout += data;
      if (stdout.length > 30000) { exceeded = true; child.kill(); }
    });
    child.stderr.on('data', data => {
      stderr += data;
      if (stderr.length > 30000) { exceeded = true; child.kill(); }
    });
    child.once('error', error => { clearTimeout(timer); reject(error); });
    child.once('close', exit => {
      clearTimeout(timer);
      if (exceeded) reject(new Error('Fixed Office probe exceeded its output limit'));
      else resolve({exit, stdout, stderr});
    });
  });
  Object.assign(receipt, result, {finished_at: new Date().toISOString()});
  appendFileSync(join(output, 'calls.jsonl'), JSON.stringify(receipt) + '\n');
  return {content: [{type: 'text', text: JSON.stringify(receipt)}], isError: result.exit !== 0};
}

createInterface({input: process.stdin}).on('line', async line => {
  let request;
  try {
    request = JSON.parse(line);
    if (request.id === undefined) return;
    let result;
    switch (request.method) {
      case 'initialize':
        result = {protocolVersion: request.params?.protocolVersion || '2024-11-05', capabilities: {tools: {}}, serverInfo: {name: 'local-office-fixture', version: '0.2.0'}};
        break;
      case 'ping': result = {}; break;
      case 'tools/list': result = {tools: [tool]}; break;
      case 'tools/call': {
        const args = request.params?.arguments === undefined ? {} : request.params.arguments;
        if (request.params?.name !== tool.name || args === null || typeof args !== 'object' || Array.isArray(args) || Object.keys(args).length) {
          throw new Error('Only the fixed no-argument operation is exposed');
        }
        result = await execute();
        break;
      }
      default:
        send({jsonrpc: '2.0', id: request.id, error: {code: -32601, message: 'Method not found'}});
        return;
    }
    send({jsonrpc: '2.0', id: request.id, result});
  } catch (error) {
    if (request?.id !== undefined) send({jsonrpc: '2.0', id: request.id, error: {code: -32603, message: error.message}});
  }
});
