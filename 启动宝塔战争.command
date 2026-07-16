#!/bin/bash
cd "$(dirname "$0")/web" || exit 1

if [ ! -f "index.html" ]; then
  osascript -e 'display alert "找不到游戏文件" message "请先运行 deploy.sh 导出网页版。"'
  exit 1
fi

PORT=8765
while lsof -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; do
  PORT=$((PORT + 1))
done

echo "正在启动宝塔战争..."
echo "浏览器地址: http://localhost:${PORT}/index.html"
echo "关闭此窗口即可停止游戏服务器。"

python3 -m http.server "$PORT" --bind 127.0.0.1 >/dev/null 2>&1 &
SERVER_PID=$!
sleep 1
open "http://127.0.0.1:${PORT}/index.html"
wait "$SERVER_PID"
