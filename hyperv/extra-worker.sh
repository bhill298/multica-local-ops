#!/usr/bin/env bash
set -euo pipefail
umask 077
action=${1:-}
name=${2:-}
base=${3:-codex}
[[ $name =~ ^[a-z][a-z0-9-]{0,39}$ ]] || { echo "Use a lowercase worker name (1-40 letters, digits or hyphens)." >&2; exit 2; }
[[ $base =~ ^(codex|claude|agy)$ ]] || { echo "Unknown worker base." >&2; exit 2; }
root=/var/lib/multica-local/extra-workers
mkdir -p "$root"
exec 9>"$root/$name.lock"
flock -n 9 || { echo "Another operation is using this worker." >&2; exit 1; }
settings="$root/$name.env"
if [[ $action == create && ! -f $settings ]]; then
    printf 'WORKER_BASE=%s\nWORKER_NAME=%s\n' "$base" "$name" > "$settings.new"
    mv "$settings.new" "$settings"
fi
[[ -f $settings ]] || { echo "Create worker '$name' first." >&2; exit 1; }
unset WORKER_BASE WORKER_NAME
compose=(docker compose -p "multica-extra-$name" --env-file "$settings" -f /opt/multica-local/hyperv/extra-worker.compose.yaml)
running=$("${compose[@]}" ps --status running -q worker)
case "$action" in
    create)
        grep -Fxq "WORKER_BASE=$base" "$settings" || { echo "This worker already uses a different base." >&2; exit 1; }
        if [[ -z $running ]]; then "${compose[@]}" create worker; fi
        echo "Open this worker's shell, sign in with the daily workspace's Multica token, then start it." ;;
    shell)
        if [[ -n $running ]]; then exec "${compose[@]}" exec worker bash; fi
        exec "${compose[@]}" run --rm --no-deps --entrypoint bash worker ;;
    start)
        if [[ -n $running ]]; then echo "Worker '$name' is already running."; exit 0; fi
        "${compose[@]}" run --rm -T --no-deps --entrypoint multica worker workspace list >/dev/null ||
            { echo "Sign in to the daily workspace from the worker shell first." >&2; exit 1; }
        "${compose[@]}" up -d worker ;;
    stop|remove)
        if [[ -n $running ]]; then
            count=$("${compose[@]}" exec -T worker multica daemon status --output json | python3 -c 'import json,sys; print(json.load(sys.stdin)["active_task_count"])')
            [[ $count == 0 ]] || { echo "Worker has $count active tasks." >&2; exit 1; }
        fi
        if [[ $action == stop ]]; then "${compose[@]}" stop worker
        else
            "${compose[@]}" down --volumes
            rm -f -- "$settings"
        fi ;;
    *) echo "Choose create, shell, start, stop or remove." >&2; exit 2 ;;
esac
