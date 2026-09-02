# Cross Web App Testing — 測試計劃

## 專案概述

- **App 名稱**：Cross Web App Testing (`cross-webpage-and-ios-app-testing`)
- **平台**：iOS (iPhone 為主，暫不支援 iPad 多工特性)
- **UI 框架**：UIKit（不使用 SwiftUI）
- **最低版本**：iOS 16.0
- **Bundle ID**：`com.aaronyen.crosswebapptesting`
- **URL Scheme**：`crosswebapp`

## 測試範圍

| 類型 | 工具 | 位置 | 說明 |
|---|---|---|---|
| 單元測試 | XCTest | `CrossWebAppTestingTests/` | ViewController 基本載入行為 |
| UI 測試 | XCUITest | `CrossWebAppTestingUITests/` | 畫面初始狀態、元件存在性 |
| 手動測試 | — | 本文件下方「手動測試案例」 | 跨 App／Safari 的完整跳轉流程，需要真實 Safari + App 互動，無法用 XCUITest 單獨模擬 |

## 自動化測試執行方式

```bash
# 1. 產生 / 更新 Xcode 專案（修改 project.yml 或新增檔案後都要重跑）
./Scripts/generate_project.sh

# 2. 在模擬器上執行全部測試
./Scripts/run_tests.sh "iPhone 17"
```

測試結果會輸出至 `TestResults/results.xcresult`，可用 Xcode 開啟檢視，或用 `xcrun xcresulttool` 解析。

## 測試案例追蹤

> 新增測試案例時，請在此表格中登記，並註明是自動化（連結到對應的 XCTest/XCUITest 方法）還是手動。

| ID | 名稱 | 類型 | 狀態 | 對應測試 |
|---|---|---|---|---|
| TC-001 | App 可正常啟動並顯示初始畫面（尚未收到網址） | 自動化 (UI) | ✅ 已建立 | `CrossWebAppTestingUITests.testAppLaunchesAndShowsInitialState` |
| TC-002 | 主畫面 ViewController 可正常載入 | 自動化 (Unit) | ✅ 已建立 | `CrossWebAppTestingTests.testViewControllerLoadsWithoutCrashing` |
| TC-003 | Safari 開啟網頁 → 點擊「開啟 App」→ App 被 `crosswebapp://` 喚起並顯示收到的網址 | 手動 | ⬜ 待執行 | 見下方手動測試案例 |
| TC-004 | App 內點擊「回到網頁」→ 成功跳回 Safari 且原分頁狀態維持 | 手動 | ⬜ 待執行 | 見下方手動測試案例 |

## 手動測試案例

### TC-003 / TC-004：完整跨 App 流程

**前置條件**：
- `pages/cross-webpage-and-app-testing/` 網頁已發布到 GitHub Pages。
- 本 App 已透過 Xcode 或 `run_tests.sh` build 過一次到目標模擬器／裝置（系統才會註冊 `crosswebapp://` scheme）。

**步驟**：
1. 在模擬器／實機的 Safari 開啟已發布的網頁網址。
2. （可選）在網頁上瀏覽、捲動到某個特定位置，確認之後能驗證「狀態維持」。
3. 點擊網頁上的「開啟 App」按鈕。
4. **預期**：跳出系統詢問是否開啟 App（或直接開啟，視系統設定），本 App 前景啟動並顯示「已從網頁開啟：`<完整網址含 returnURL>`」，「回到網頁」按鈕為可點擊狀態。
5. 點擊 App 內的「回到網頁」按鈕。
6. **預期**：切回 Safari，且回到步驟 2 瀏覽的同一個分頁、同一個捲動位置（Safari 分頁狀態沒有遺失）。

## 已知限制 / 待辦

- 跨 App 喚起／跳轉的完整流程目前只能手動驗證，XCUITest 無法直接操作 Safari 與 App 之間的系統層級跳轉。
- 尚未設定 CI（如 GitHub Actions / Xcode Cloud）自動跑測試。
