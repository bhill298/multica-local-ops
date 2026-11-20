#!/bin/bash
set -euo pipefail

case "${1:---check}" in
  --check) install=false ;;
  --install) install=true ;;
  *) echo "Usage: bash setup-packages.sh [--check|--install]" >&2; exit 2 ;;
esac
source /etc/os-release
profile="$(dirname "$0")/packages/${VERSION_CODENAME:-unknown}.list"
if [[ "$ID" != ubuntu || ! -f "$profile" ]]; then
  echo "No Ubuntu package profile for $PRETTY_NAME. Add and validate $profile first." >&2
  exit 1
fi
if (( EUID != 0 )); then
  echo "Run this guest setup with sudo so apt can refresh its package index." >&2
  exit 1
fi
mapfile -t packages < "$profile"
apt-get update
if ! apt-get -s --no-install-recommends install "${packages[@]}"; then
  echo "Package resolution failed for $PRETTY_NAME. Check the enabled repositories and names in $profile." >&2
  exit 1
fi
if [[ "$install" == true ]]; then
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${packages[@]}"
fi
