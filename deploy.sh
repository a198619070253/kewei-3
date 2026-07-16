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

# Force English UI in the browser (ignore system Chinese locale).
python3 - <<'PY'
from pathlib import Path
path = Path("web/index.html")
text = path.read_text(encoding="utf-8")
needle = "\t\tengine.startGame({"
if needle not in text:
    raise SystemExit("Could not patch web locale: startGame block missing")
text = text.replace(
    needle,
    "\t\tengine.startGame({\n\t\t\t'locale': 'en',",
    1,
)
path.write_text(text, encoding="utf-8")
print("Patched web locale to en")
PY

echo "Export complete: $PROJECT_DIR/web/"
echo "Double-click \"Launch Pagoda Wars.command\" to play."
