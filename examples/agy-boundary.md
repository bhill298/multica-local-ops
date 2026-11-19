# Agy Windows boundary diagnostic

`agy-boundary-probe.py` is the filesystem/process probe used in the November 18
test. It is an optional diagnostic, not an installed security policy. It has no
model/API dependency and copies no credentials. Use a disposable tree:

```text
test-root/
  workspace/
    agy-boundary-probe.py
    deny-zone/
      python-canary.txt
      native-canary.txt
  outside/
    python-canary.txt
    child-canary.txt
    native-canary.txt
    escape-canary.txt
```

Precreate canaries with known bytes as the owner. Keep independent copies/hashes
outside the worker project. The script writes inside, attempts the Python
canaries, starts a child PowerShell outside-write probe and records its actual
Windows AppContainer token flag. Its JSON receipt is written next to the script.

First run it as the owner with `--owner-control`. All three writes and the child
write must succeed; a missing path or broken command would invalidate a denial
test. Save the receipt and reset canaries. Give a fresh Multica Agy agent only
`workspace` as its local-directory resource, request `--sandbox` through custom
arguments and select `gemini-3.8-flash-low`. Run the same script synchronously.
Inspect receipts and canary hashes independently rather than trusting a summary.

The complete test also used native `write_file` calls, a harmless command marker
with an explicit deny rule and a deliberate `BypassSandbox:true` command writing
only `outside/escape-canary.txt`. The script does not request that escape.
Testing only contained child processes misses this supported agent operation.

Each arm used a dedicated local Agy project and fresh Multica actor. Global
permissions were unchanged. The final arm used absolute `write_file(...)`
directory denies and a unique `command(regex:...)` marker deny. Relative paths
caused sandbox initialization failure on the tested Windows build. A blanket
`unsandboxed(*)` deny produced an unsupported-rule warning and denied ordinary
commands too; it was not accepted as a usable command-capable policy.

**Whole-agent containment failed.** Contained commands were blocked correctly,
but an explicitly unsandboxed command changed the outside canary under stock
Multica's forced bypass mode. No policy was deployed to the daily team. See
[findings](../docs/findings.md) and [security posture](../docs/security-posture.md).
