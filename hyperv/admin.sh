#!/bin/bash
set -euo pipefail
cd /opt/multica-local/hyperv
case "${1:-}" in
  start) shift; exec python3 admin.py "$@" ;;
  auth)
    if [[ $# -eq 1 ]]; then
      exec python3 admin_provider.py auth
    fi
    shift; exec python3 admin.py --auth "$@" ;;
  stop)
    systemctl disable --now multica-vm-admin.service
    docker compose -p multica-owner-only -f /var/lib/multica-owner-only/compose.json stop
    ;;
  *) echo "Choose start, auth or stop." >&2; exit 2 ;;
esac
