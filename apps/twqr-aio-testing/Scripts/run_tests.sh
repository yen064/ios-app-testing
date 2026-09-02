#!/bin/bash
# 在模擬器上執行 Unit Tests + UI Tests
# 用法: ./Scripts/run_tests.sh ["iPhone 17"]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(dirname "$SCRIPT_DIR")"
DEVICE_NAME="${1:-iPhone 17}"

cd "$APP_DIR"

if [ ! -d "TWQRAioTesting.xcodeproj" ]; then
  echo "找不到 TWQRAioTesting.xcodeproj，先執行 Scripts/generate_project.sh" >&2
  exit 1
fi

rm -rf ./TestResults
mkdir -p ./TestResults

if command -v xcbeautify >/dev/null 2>&1; then
  xcodebuild test \
    -project TWQRAioTesting.xcodeproj \
    -scheme TWQRAioTesting \
    -destination "platform=iOS Simulator,name=${DEVICE_NAME}" \
    -resultBundlePath ./TestResults/results.xcresult \
    | xcbeautify
else
  xcodebuild test \
    -project TWQRAioTesting.xcodeproj \
    -scheme TWQRAioTesting \
    -destination "platform=iOS Simulator,name=${DEVICE_NAME}" \
    -resultBundlePath ./TestResults/results.xcresult
fi
