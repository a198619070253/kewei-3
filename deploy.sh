#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
GODOT="/Applications/Godot.app/Contents/MacOS/Godot"
OUTPUT="$PROJECT_DIR/web/index.html"

if [ ! -x "$GODOT" ]; then
  echo "未找到 Godot，请确认已安装 Godot 4.7。"
  exit 1
fi

mkdir -p "$PROJECT_DIR/web"
echo "正在导出网页版..."
"$GODOT" --path "$PROJECT_DIR" --headless --export-release "Web" "$OUTPUT"
echo "导出完成: $PROJECT_DIR/web/"
echo "双击「启动宝塔战争.command」即可游玩。"
