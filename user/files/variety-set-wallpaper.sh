#!/usr/bin/env bash
PIDFILE=/tmp/seaglass-debounce.pid
if [ -f "$PIDFILE" ]; then
  kill "$(cat "$PIDFILE")" 2>/dev/null
fi
(sleep 5 && seaglass-theme) &
echo $! > "$PIDFILE"
