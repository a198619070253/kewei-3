#!/bin/bash
cd "$(dirname "$0")/web" || exit 1

if [ ! -f "index.html" ]; then
  osascript -e 'display alert "Game files not found" message "Run deploy.sh first to export the web build."'
  exit 1
fi

PORT=8765
while lsof -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; do
  PORT=$((PORT + 1))
done

echo "Starting Pagoda Wars..."
echo "Browser URL: http://127.0.0.1:${PORT}/index.html"
echo "Close this window to stop the local server."

python3 -m http.server "$PORT" --bind 127.0.0.1 >/dev/null 2>&1 &
SERVER_PID=$!
sleep 1
open "http://127.0.0.1:${PORT}/index.html"
wait "$SERVER_PID"
