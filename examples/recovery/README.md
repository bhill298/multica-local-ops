# Durable reboot checkpoint fixture

This is the unchanged small Windows/Python checkpoint source from the successful
November 18 stock-Multica physical restart test. It contains no credentials,
workspace/agent IDs or generated results. Copy `checkpoints.py` to an otherwise
empty disposable project; do not run the 45-minute writer in this source folder.

Create `initial.json` there before the first attempt:

```powershell
python -c "import ctypes,time,json; from pathlib import Path; ctypes.windll.kernel32.GetTickCount64.restype=ctypes.c_ulonglong; Path('initial.json').write_text(json.dumps({'epoch':time.time(),'boot_epoch':time.time()-ctypes.windll.kernel32.GetTickCount64()/1000}))"
```

Attach only that project directory to a fresh test actor. The writer command is
`python ./checkpoints.py`; `python ./checkpoints.py --verify` validates a current
prefix without starting the writer. It uses an exclusive writer lock, numbered
hash-chain records, flush and fsync. It preserves rather than rewrites a valid
prefix. Malformed or duplicate records fail validation.

On the first boot it writes for at most 45 minutes while awaiting the operator's
restart. On a new Windows boot, a fresh attempt validates the existing chain,
adds 15 records over about 30 seconds and writes `receipt.json`. A boot-epoch
difference over 30 seconds identifies the new boot. This is a controlled Restart
fixture, not a power-loss durability guarantee.

Before dispatch, register a finite independent root timer and instruct the lead
to watch actual terminal runs, avoid duplicates, retry only a failed/interrupted
worker and accept the child/root after independent validation. Save a byte prefix
outside the worker directory before signaling the operator to restart. After
restart compare the bytes, validate the complete chain and changed boot, inspect
actual runs/statuses, and check guards drain. Read-only Windows boot/logon and
Docker/process startup timestamps distinguish pre-login from post-login recovery.
Never initiate a user's restart automatically.

The completed test preserved 115 existing records and added 15, with the saved
20-record prefix unchanged and all 130 final records valid. Both issues closed
without corrective prompts. These are historical results; a new run has its own
counts. The selected deployment required sign-in before recovery. See
[findings](../../docs/findings.md) and [testing guide](../../docs/testing-guide.md).
