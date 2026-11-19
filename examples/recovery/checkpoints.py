"""Append durable hash-chain checkpoints until a different Windows boot resumes us."""
import ctypes
import hashlib
import json
import msvcrt
import os
import sys
import time
from pathlib import Path

P = Path(__file__).resolve().parent
ctypes.windll.kernel32.GetTickCount64.restype = ctypes.c_ulonglong

def boot_epoch():
    return time.time() - ctypes.windll.kernel32.GetTickCount64() / 1000

def validate():
    dest = P / 'checkpoints.jsonl'
    rows = [json.loads(line) for line in dest.read_text().splitlines()] if dest.exists() else []
    prev = '0' * 64
    for i, row in enumerate(rows):
        digest = hashlib.sha256(f'{i}:{prev}'.encode()).hexdigest()
        assert row == dict(i=i, prev=prev, hash=digest), f'Invalid checkpoint {i}'
        prev = digest
    return rows, prev

if '--verify' in sys.argv:
    rows, prev = validate()
    print(json.dumps(dict(count=len(rows), last_hash=prev, verified=True)))
    raise SystemExit(0)

with (P / 'writer.lock').open('a+b') as lock:
    lock.seek(0)
    lock.write(b'0')
    lock.flush()
    lock.seek(0)
    msvcrt.locking(lock.fileno(), msvcrt.LK_NBLCK, 1)
    initial = json.loads((P / 'initial.json').read_text())
    current_boot = boot_epoch()
    new_boot = abs(current_boot - initial['boot_epoch']) > 30
    rows, prev = validate()
    start_count = len(rows)
    with (P / 'sessions.jsonl').open('a', encoding='utf-8') as sessions:
        sessions.write(json.dumps(dict(pid=os.getpid(), epoch=time.time(),
                                      boot_epoch=current_boot, start_count=start_count,
                                      different_boot=new_boot)) + '\n')
        sessions.flush()
        os.fsync(sessions.fileno())
    deadline = time.monotonic() + (90 if new_boot else 2700)
    with (P / 'checkpoints.jsonl').open('a', encoding='utf-8', newline='\n') as out:
        i = start_count
        while time.monotonic() < deadline:
            digest = hashlib.sha256(f'{i}:{prev}'.encode()).hexdigest()
            out.write(json.dumps(dict(i=i, prev=prev, hash=digest)) + '\n')
            out.flush()
            os.fsync(out.fileno())
            prev = digest
            i += 1
            if new_boot and i - start_count >= 15:
                break
            time.sleep(2)
    if not new_boot:
        raise SystemExit('No new Windows boot within 45 minutes; bounded test ended.')
    rows, prev = validate()
    receipt = dict(count=len(rows), last_hash=prev, verified=True,
                   original_boot_epoch=initial['boot_epoch'], resumed_boot_epoch=current_boot,
                   resumed_prefix_count=start_count, new_boot_checkpoints=len(rows)-start_count)
    with (P / 'receipt.json').open('w', encoding='utf-8') as out:
        json.dump(receipt, out, indent=2)
        out.flush()
        os.fsync(out.fileno())
    print(json.dumps(receipt))
