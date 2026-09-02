# cross-webpage-and-ios-app-testing — App 層級規範

參見 repo 層級規範：[../../CLAUDE.md](../../CLAUDE.md)

## 基本資訊

- **平台**：iOS，僅 iPhone（`TARGETED_DEVICE_FAMILY: "1"`），未支援 iPad
- **UI 框架**：UIKit（Storyboard + AutoLayout），**不使用 SwiftUI**
- **最低版本**：iOS 16.0
- **Bundle ID**：`com.aaronyen.crosswebapptesting`（Tests: `.tests`，UITests: `.uitests`）
- **語言**：zh-Hant（development language）
- **App Delegate 生命週期**：UIKit App Delegate + Scene Delegate（`UISceneStoryboardFile: Main`）

## 這個 App 的用途

搭配 [`../../pages/cross-webpage-and-app-testing/`](../../pages/cross-webpage-and-app-testing/) 這個網頁，示範「Safari 網頁 → 喚起 iOS App → 回到 Safari」的跨網頁與 App 溝通流程：

1. 網頁（發布於 GitHub Pages）上有個「開啟 App」按鈕，點擊後導向
   `crosswebapp://open?returnURL=<目前網頁網址 URL-encoded>`。
2. 本 App 註冊了 `crosswebapp` 這個 Custom URL Scheme，被喚起後解析出 `returnURL`，
   畫面顯示收到的完整網址，並啟用「回到網頁」按鈕。
3. 使用者點擊「回到網頁」，App 用 `UIApplication.shared.canOpenURL` 檢查
   `returnURL` 是否可開啟，可以的話呼叫 `UIApplication.shared.open(returnURL)` 跳回 Safari。
   因為只是切回同一個 Safari App／分頁，Safari 原本的頁面狀態會維持。

## 技術決策

- **XcodeGen 驅動**：`project.yml` 是唯一真實來源，`CrossWebAppTesting.xcodeproj` 由 `Scripts/generate_project.sh` 產生，不進版控。修改 target/檔案結構後務必重跑。
- **UIKit 而非 SwiftUI**：跟 repo 內其他 app 保持一致。
- **為什麼用 Custom URL Scheme 而非 Universal Links**：這是本機測試用的示範專案，Universal Links 需要網域上的 `apple-app-site-association` 等額外設定，Custom URL Scheme 實作最簡單、足以驗證「網頁喚起 App、App 跳回網頁」這個流程。
- **`returnURL` 由網頁端透過 query string 傳入，App 不寫死回跳網址**：這樣 App 不需要知道網頁實際部署在哪個網址，只要網頁呼叫時帶上 `returnURL` 參數即可。
- **`AppLaunchState`（`AppLaunchState.swift`）**：處理冷啟動時序問題——App 被 `crosswebapp://` 冷啟動時，`SceneDelegate.willConnectTo` 收到 URL 的當下 `ViewController` 的 view 還沒建立、還沒訂閱 `NotificationCenter`，直接發通知會漏接，所以先暫存在這個單例，等 `ViewController.viewDidLoad` 時再讀取。若是 App 已在背景／前景時被再次喚起，則直接透過 `NotificationCenter`（`.crossWebAppDidReceiveURL`）通知已存在的 `ViewController`。
- **測試預設模擬器**：`iPhone 17`（本機環境目前可用的機型清單以 `xcrun simctl list devices available` 為準，若模擬器不存在請改用 `Scripts/run_tests.sh "<裝置名稱>"` 指定其他機型）。

## 目錄結構

```
apps/cross-webpage-and-ios-app-testing/
├── CLAUDE.md
├── project.yml
├── CrossWebAppTesting.xcodeproj/       ← xcodegen 產生，不進版控
├── CrossWebAppTesting/                  ← app 原始碼
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── AppLaunchState.swift
│   ├── ViewController.swift
│   ├── Base.lproj/
│   │   ├── Main.storyboard
│   │   └── LaunchScreen.storyboard
│   ├── Assets.xcassets/
│   └── Resources/
├── CrossWebAppTestingTests/             ← Unit tests (XCTest)
├── CrossWebAppTestingUITests/           ← UI tests (XCUITest)
├── Scripts/
│   ├── generate_project.sh              ← 執行 `xcodegen generate`
│   └── run_tests.sh                     ← 在模擬器上跑 Unit + UI tests
└── docs/
    └── TestPlan.md                      ← 測試計劃與案例追蹤表
```

## 常用指令

```bash
cd apps/cross-webpage-and-ios-app-testing

# 產生 / 重新產生 Xcode 專案
./Scripts/generate_project.sh

# 執行全部自動化測試（預設 iPhone 17 模擬器）
./Scripts/run_tests.sh

# 指定其他模擬器
./Scripts/run_tests.sh "iPhone 15 Pro"
```

## 手動驗證跨 App 流程（模擬器）

`crosswebapp://` scheme 要先透過 `generate_project.sh` 產生的專案 build 一次到模擬器上，系統才認得這個 scheme。之後可以直接在模擬器裡用 Safari 開啟已發布的網頁測試，或用指令直接模擬喚起：

```bash
xcrun simctl openurl booted "crosswebapp://open?returnURL=https%3A%2F%2Fexample.com"
```

## 目前狀態

- 已驗證：`xcodegen generate` 可成功產生專案。
- 待辦：實機／模擬器上跑一次完整「Safari → App → 回到 Safari」流程並記錄結果於 `docs/TestPlan.md`。

## 測試

詳見 [docs/TestPlan.md](docs/TestPlan.md)。
