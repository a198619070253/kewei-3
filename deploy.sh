#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
GODOT="/Applications/Godot.app/Contents/MacOS/Godot"
OUTPUT="$PROJECT_DIR/web/index.html"

if [ ! -x "$GODOT" ]; then
  echo "Godot not found. Please install Godot 4.7."
  exit 1
fi

mkdir -p "$PROJECT_DIR/web"
echo "Exporting web build..."
"$GODOT" --path "$PROJECT_DIR" --headless --export-release "Web" "$OUTPUT"
echo "Export complete: $PROJECT_DIR/web/"
echo "Double-click \"Launch Pagoda Wars.command\" to play."
