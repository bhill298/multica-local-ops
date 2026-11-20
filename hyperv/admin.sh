#!/bin/bash
set -euo pipefail
cd /opt/multica-local/hyperv
case "${1:-}" in
  start) exec python3 admin.py ;;
  auth) exec python3 admin.py --auth ;;
  stop)
    systemctl stop multica-manual-admin.service || true
    docker compose -p multica-owner-only -f /var/lib/multica-owner-only/compose.json stop
    ;;
  *) echo "Choose start, auth or stop." >&2; exit 2 ;;
esac
