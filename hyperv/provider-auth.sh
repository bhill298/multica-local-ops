#!/bin/bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
provider=${2:-}
case "$provider" in codex|claude|agy) ;; *) echo "Choose codex, claude or agy." >&2; exit 2 ;; esac
case "${1:-}" in
  login) python3 admin_provider.py auth --provider "$provider" ;;
  copy) ;;
  *) echo "Choose login or copy." >&2; exit 2 ;;
esac
daily=(docker compose -p multica-vm -f /var/lib/multica-local/compose.json exec -T --user 1000 "$provider")
# Only code is passed as an argument. Credentials stay in this in-guest pipe.
runuser -u multica-vm-admin -- python3 -B provider_auth_cache.py export "$provider" |
  "${daily[@]}" python3 -c "$(cat provider_auth_cache.py)" import "$provider"
if [[ "$provider" == codex ]]; then "${daily[@]}" codex login status; fi
echo "Synchronized the $provider login to the daily worker."
