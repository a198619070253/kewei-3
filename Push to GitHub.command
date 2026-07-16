#!/bin/bash
cd "$(dirname "$0")" || exit 1

GH="$(dirname "$0")/.tools/gh"
if [ ! -x "$GH" ]; then
  osascript -e 'display alert "GitHub tool missing" message "Please ask AI to restore .tools/gh"'
  exit 1
fi

echo "======================================"
echo "  Pagoda Wars - Push to GitHub"
echo "======================================"
echo ""
echo "Repository: https://github.com/a198619070253/kewei-3"
echo ""

if ! "$GH" auth status >/dev/null 2>&1; then
  echo "First time setup: sign in to GitHub."
  echo "Complete authorization in your browser when prompted."
  echo ""
  "$GH" auth login --hostname github.com --git-protocol https --web
  if [ $? -ne 0 ]; then
    echo ""
    echo "Sign-in failed. Please try again."
    read -r -p "Press Enter to close..."
    exit 1
  fi
fi

echo ""
echo "Pushing main branch..."
git push -u origin main

if [ $? -eq 0 ]; then
  echo ""
  echo "Push succeeded!"
  echo ""
  echo "Next steps:"
  echo "1. Open https://github.com/a198619070253/kewei-3/settings/pages"
  echo "2. Set Source to GitHub Actions"
  echo "3. Wait for Actions to finish, then the game goes live on GitHub Pages"
  open "https://github.com/a198619070253/kewei-3/actions"
else
  echo ""
  echo "Push failed. See the error above."
fi

echo ""
read -r -p "Press Enter to close..."
