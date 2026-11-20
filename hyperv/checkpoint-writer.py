"""Linux pilot fixture. Append a verified chain and finish after a guest boot."""
import argparse
import fcntl
import hashlib
import json
import os
from pathlib import Path
import time

args=argparse.ArgumentParser()
args.add_argument("folder",type=Path)
args.add_argument("--verify",action="store_true")
args=args.parse_args()
folder=args.folder
boot=Path("/proc/sys/kernel/random/boot_id").read_text().strip()
first=(folder/"initial-boot").read_text().strip()
chain=folder/"records.jsonl"
lock=(folder/"lock").open("a")
if not args.verify: fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)


def digest(row):
    return hashlib.sha256(json.dumps(row,sort_keys=True,separators=(",",":")).encode()).hexdigest()


seq=0
prev="0"*64
new_count=0
if chain.exists():
    for line in chain.read_text().splitlines():
        row=json.loads(line)
        check=row.pop("hash")
        if row["n"]!=seq or row["prev"]!=prev or digest(row)!=check: raise ValueError(f"Bad record {seq}")
        seq+=1
        prev=check
        new_count+=row["boot"]==boot and boot!=first
if args.verify:
    print(json.dumps({"records":seq,"newBootRecords":new_count,"complete":new_count>=10,"lastHash":prev}))
    raise SystemExit(0 if new_count>=10 else 2)
deadline=time.monotonic()+3600
with chain.open("a") as fp:
    while new_count<10:
        if time.monotonic()>deadline: raise TimeoutError("Operator reboot window elapsed")
        row={"n":seq,"boot":boot,"utc":time.time(),"prev":prev}
        prev=digest(row)
        row["hash"]=prev
        fp.write(json.dumps(row)+"\n")
        fp.flush()
        os.fsync(fp.fileno())
        seq+=1
        new_count+=boot!=first
        time.sleep(2)
print(f"Completed {seq} linked records with {new_count} after reboot")
