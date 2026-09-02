# TWQR AIO Testing — 測試計劃

## 專案概述

- **App 名稱**：TWQR AIO Testing (`twqr-aio-testing`)
- **平台**：iOS (iPhone 為主，暫不支援 iPad 多工特性)
- **UI 框架**：UIKit（不使用 SwiftUI）
- **最低版本**：iOS 16.0
- **Bundle ID**：`com.aaronyen.twqraiotesting`

## 測試範圍

| 類型 | 工具 | 位置 | 說明 |
|---|---|---|---|
| 單元測試 | XCTest | `TWQRAioTestingTests/` | 商業邏輯、ViewModel、資料處理 |
| UI 測試 | XCUITest | `TWQRAioTestingUITests/` | 畫面互動、導覽流程、關鍵使用者路徑 |
| 手動測試 | — | 本文件下方「手動測試案例」 | 尚無法自動化或需要人工判斷視覺效果的項目 |

## 自動化測試執行方式

```bash
# 1. 產生 / 更新 Xcode 專案（修改 project.yml 或新增檔案後都要重跑）
./Scripts/generate_project.sh

# 2. 在模擬器上執行全部測試
./Scripts/run_tests.sh "iPhone 16"
```

測試結果會輸出至 `TestResults/results.xcresult`，可用 Xcode 開啟檢視，或用 `xcrun xcresulttool` 解析。

## 測試案例追蹤

> 新增測試案例時，請在此表格中登記，並註明是自動化（連結到對應的 XCTest/XCUITest 方法）還是手動。

| ID | 名稱 | 類型 | 狀態 | 對應測試 |
|---|---|---|---|---|
| TC-001 | App 可正常啟動並顯示 WebView | 自動化 (UI) | ✅ 已建立 | `TWQRAioTestingUITests.testAppLaunchesAndShowsWebView` |
| TC-002 | 主畫面 ViewController 可正常載入 | 自動化 (Unit) | ✅ 已建立 | `TWQRAioTestingTests.testViewControllerLoadsWithoutCrashing` |

## 手動測試案例

> 目前尚無，待功能開發後補充。

## 已知限制 / 待辦

- 主畫面為 WKWebView，目前載入預留位置網址（`https://www.apple.com`），待實際要串接的網址確定後於 `ViewController.swift` 更新。
- 尚未設定 CI（如 GitHub Actions / Xcode Cloud）自動跑測試，待專案功能明確後補上。
