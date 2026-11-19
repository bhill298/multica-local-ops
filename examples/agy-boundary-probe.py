"""Benign probes: only write operator-created disposable canaries."""
import ctypes
import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path

P=Path(__file__).resolve().parent
TARGETS={'inside':P/'inside-python.txt',
         'outside':P.parent/'outside/python-canary.txt',
         'denied_inside':P/'deny-zone/python-canary.txt'}

def token_info():
    token=ctypes.c_void_p()
    adv=ctypes.windll.advapi32
    kernel=ctypes.windll.kernel32
    kernel.GetCurrentProcess.restype=ctypes.c_void_p
    adv.OpenProcessToken.argtypes=[ctypes.c_void_p,ctypes.c_ulong,ctypes.POINTER(ctypes.c_void_p)]
    adv.GetTokenInformation.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_void_p,ctypes.c_ulong,ctypes.POINTER(ctypes.c_ulong)]
    kernel.CloseHandle.argtypes=[ctypes.c_void_p]
    if not adv.OpenProcessToken(kernel.GetCurrentProcess(),8,ctypes.byref(token)):
        return {'error':kernel.GetLastError()}
    try:
        flag=ctypes.c_ulong()
        length=ctypes.c_ulong()
        ok=adv.GetTokenInformation(token,29,ctypes.byref(flag),ctypes.sizeof(flag),ctypes.byref(length))
        return {'appcontainer':bool(flag.value)} if ok else {'error':kernel.GetLastError()}
    finally: kernel.CloseHandle(token)

def attempt(path):
    try:
        with path.open('w',encoding='utf-8') as out:
            out.write('AGY_BENIGN_WRITE_PROBE\n')
            out.flush()
            os.fsync(out.fileno())
        return {'write_succeeded':True}
    except OSError as e:
        return {'write_succeeded':False,'error_type':type(e).__name__,
                'errno':e.errno,'winerror':getattr(e,'winerror',None)}

if __name__=='__main__':
    result={'pid':os.getpid(),'token':token_info(),
            'writes':{k:attempt(p) for k,p in TARGETS.items()}}
    shell=Path(os.environ.get('SystemRoot','C:/Windows'))/'System32/WindowsPowerShell/v1.0/powershell.exe'
    target=(P.parent/'outside/child-canary.txt').as_posix().replace("'","''")
    command=f"try {{ [IO.File]::WriteAllText('{target}', 'AGY_CHILD_WRITE_PROBE'); exit 0 }} catch {{ Write-Output $_.Exception.GetType().Name; exit 23 }}"
    try:
        proc=subprocess.run([str(shell),'-NoProfile','-NonInteractive','-Command',command],
                            capture_output=True,text=True,timeout=25,
                            creationflags=subprocess.CREATE_NO_WINDOW)
        result['child_process']={'exit':proc.returncode,'stdout':proc.stdout.strip()[:500],
                                 'stderr':proc.stderr.strip()[:500]}
    except (OSError,subprocess.TimeoutExpired) as e:
        result['child_process']={'error_type':type(e).__name__}
    dest=P/('owner-control.json' if '--owner-control' in sys.argv else 'probe-results.json')
    dest.write_text(json.dumps(result,indent=2),encoding='utf-8')
    print(json.dumps(result))
