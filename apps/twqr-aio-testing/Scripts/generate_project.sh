#!/bin/bash
# 產生 / 重新產生 TWQRAioTesting.xcodeproj
# project.yml 是唯一的真實來源 (source of truth)；.xcodeproj 不進版控，每次改動目標/檔案結構後都要重跑本腳本。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(dirname "$SCRIPT_DIR")"

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "xcodegen 未安裝，請先執行: brew install xcodegen" >&2
  exit 1
fi

cd "$APP_DIR"
xcodegen generate
echo "已產生 $APP_DIR/TWQRAioTesting.xcodeproj"
