#!/bin/bash
# Transfer only the admin user's ChatGPT provider login to the daily Codex home.
set -euo pipefail
admin=multica-vm-admin
cli=/opt/multica-owner-bin/codex
case "${1:-}" in
  login) runuser -u "$admin" -- "$cli" login --device-auth ;;
  copy) ;;
  *) echo "Usage: codex-auth.sh login|copy" >&2; exit 2 ;;
esac
daily=(docker compose -p multica-vm -f /var/lib/multica-local/compose.json exec -T --user 1000 codex)
# The source runs as the credential owner; the destination writes as UID 1000
# inside the worker. No Windows file, guest-root read or shared mount is needed.
runuser -u "$admin" -- python3 -c '
import json, sys
from pathlib import Path
a = json.loads((Path.home()/".codex/auth.json").read_text())
if a.get("auth_mode") != "chatgpt" or not isinstance(a.get("tokens"), dict):
    sys.exit("Sign in with ChatGPT using device authorization first.")
tokens = {k: a["tokens"][k] for k in ("access_token","refresh_token","id_token","account_id") if k in a["tokens"]}
if not all(isinstance(tokens.get(k), str) and tokens[k] for k in ("access_token","refresh_token","id_token")):
    sys.exit("Incomplete ChatGPT login. Run the provider login again.")
json.dump({"auth_mode":"chatgpt","tokens":tokens,"last_refresh":a.get("last_refresh")}, sys.stdout)
' | "${daily[@]}" python3 -c '
import json, os, sys, tempfile
from pathlib import Path
a = json.load(sys.stdin)
target = Path.home()/".codex"
target.mkdir(mode=0o700, exist_ok=True)
with tempfile.NamedTemporaryFile(mode="w", dir=target, delete=False) as f:
    json.dump(a, f)
os.replace(f.name, target/"auth.json")
'
"${daily[@]}" codex login status
