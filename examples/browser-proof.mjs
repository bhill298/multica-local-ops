// Optional local capability check. Uses an isolated headless Edge instance.
import assert from 'node:assert/strict';
import {writeFile} from 'node:fs/promises';
import {dirname, join} from 'node:path';
import {fileURLToPath} from 'node:url';
import {chromium} from 'playwright-core';

const output = dirname(fileURLToPath(import.meta.url));
const browser = await chromium.launch({channel: 'msedge', headless: true, chromiumSandbox: true});
try {
  const page = await browser.newPage({viewport: {width: 640, height: 360}});
  await page.setContent(`<!doctype html><html><body>
    <h1>Local browser capability check</h1>
    <label>First number <input id="first" type="number"></label>
    <label>Second number <input id="second" type="number"></label>
    <button onclick="document.querySelector('output').textContent =
      Number(document.querySelector('#first').value) + Number(document.querySelector('#second').value)">Calculate</button>
    <output></output>
  </body></html>`);
  await page.getByLabel('First number').fill('19');
  await page.getByLabel('Second number').fill('23');
  await page.getByRole('button', {name: 'Calculate'}).click();
  const result = await page.locator('output').textContent();
  assert.equal(result, '42');
  const screenshot = join(output, 'browser-proof.png');
  await page.screenshot({path: screenshot});
  const receipt = {result, browser: browser.version(), headless: true, chromiumSandbox: true, screenshot};
  await writeFile(join(output, 'browser-proof.json'), JSON.stringify(receipt, null, 2));
  console.log(JSON.stringify(receipt));
} finally {
  await browser.close();
}
