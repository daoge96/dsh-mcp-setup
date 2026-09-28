#!/usr/bin/env bash
# dsh-mcp-setup installer (macOS / Linux)
set -euo pipefail

PROFILE="${DSH_PROFILE:-web}"
DSH_HOME="${DSH_HOME:-$HOME/.dsh}"
PATCH_DIR="$DSH_HOME/profiles/$PROFILE"
PATCH="$PATCH_DIR/cordis.patch.yml"
MARKER="# >>> dsh-mcp-setup <<<"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/cordis.patch.yml"

[ -f "$SRC" ] || { echo "找不到 $SRC"; exit 1; }

mkdir -p "$PATCH_DIR"

if [ -f "$PATCH" ] && grep -qF "$MARKER" "$PATCH"; then
  echo "检测到已有 dsh-mcp-setup 段，先移除旧段…"
  awk -v m="$MARKER" '$0==m{b=!b; next} !b' "$PATCH" > "$PATCH.tmp" && mv "$PATCH.tmp" "$PATCH"
fi

if [ -f "$PATCH" ]; then
  cp "$PATCH" "$PATCH.bak.$(date +%s)"
fi

{
  echo ""
  echo "$MARKER"
  cat "$SRC"
  echo "$MARKER"
} >> "$PATCH"

echo "✅ 已写入 $PATCH"
echo
echo "下一步："
echo "  1) 设置环境变量（或写进 ~/.dsh/.credentials.yaml）:"
echo "     export TAVILY_API_KEY=... EXA_API_KEY=... GITHUB_TOKEN=..."
echo "  2) 完全退出并重启 DSH Desktop"
