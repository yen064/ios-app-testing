# twqr-aio-testing — App 層級規範

參見 repo 層級規範：[../../CLAUDE.md](../../CLAUDE.md)

## 基本資訊

- **平台**：iOS，僅 iPhone（`TARGETED_DEVICE_FAMILY: "1"`），未支援 iPad
- **UI 框架**：UIKit（Storyboard + AutoLayout），**不使用 SwiftUI**
- **最低版本**：iOS 16.0
- **Bundle ID**：`com.aaronyen.twqraiotesting`（Tests: `.tests`，UITests: `.uitests`）
- **語言**：zh-Hant（development language）
- **App Delegate 生命週期**：UIKit App Delegate + Scene Delegate（`UISceneStoryboardFile: Main`）

## 技術決策

- **XcodeGen 驅動**：`project.yml` 是唯一真實來源，`TWQRAioTesting.xcodeproj` 由 `Scripts/generate_project.sh` 產生，不進版控。修改 target/檔案結構後務必重跑。
- **UIKit 而非 SwiftUI**：目前階段明確要求使用 UIKit，之後若要導入 SwiftUI 需另外討論並更新本文件。
- **Info.plist 由 XcodeGen 自動產生**（`GENERATE_INFOPLIST_FILE: YES` for Tests/UITests；主 app target 用 `info.properties` 內嵌設定），不手動維護 `.plist` 檔案。
- **測試預設模擬器**：`iPhone 17`（本機環境目前可用的機型清單以 `xcrun simctl list devices available` 為準，若模擬器不存在請改用 `Scripts/run_tests.sh "<裝置名稱>"` 指定其他機型）。

## 目錄結構

```
apps/twqr-aio-testing/
├── CLAUDE.md
├── project.yml
├── TWQRAioTesting.xcodeproj/       ← xcodegen 產生，不進版控
├── TWQRAioTesting/                 ← app 原始碼
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── ViewController.swift
│   ├── Base.lproj/
│   │   ├── Main.storyboard
│   │   └── LaunchScreen.storyboard
│   ├── Assets.xcassets/
│   └── Resources/
├── TWQRAioTestingTests/            ← Unit tests (XCTest)
├── TWQRAioTestingUITests/          ← UI tests (XCUITest)
├── Scripts/
│   ├── generate_project.sh         ← 執行 `xcodegen generate`
│   └── run_tests.sh                ← 在模擬器上跑 Unit + UI tests
└── docs/
    └── TestPlan.md                 ← 測試計劃與案例追蹤表
```

## 常用指令

```bash
cd apps/twqr-aio-testing

# 產生 / 重新產生 Xcode 專案
./Scripts/generate_project.sh

# 執行全部自動化測試（預設 iPhone 17 模擬器）
./Scripts/run_tests.sh

# 指定其他模擬器
./Scripts/run_tests.sh "iPhone 15 Pro"
```

## 目前狀態

- 主畫面（`ViewController`）為 `WKWebView`，App 啟動後直接載入網址。
  - 目前載入的是指定的贊助頁面（見 `ViewController.swift` 內的 `targetURL`），之後若要換成其他頁面直接更新這個常數即可。
  - `webView` 有設定 `accessibilityIdentifier`，UI test 用這個 identifier 確認 WebView 有正常顯示。
  - `ViewController` 實作 `WKNavigationDelegate`，攔截每一次導覽（包含使用者點擊頁面上的連結）並用 `os.log`（`Logger`，subsystem `com.aaronyen.twqraiotesting`, category `WebView`）記錄導覽類型與目標網址，目前一律 `decisionHandler(.allow)` 放行，不做攔截或改寫。可用 Console.app 或 `xcrun simctl spawn <device> log stream --predicate 'subsystem == "com.aaronyen.twqraiotesting"'` 即時查看。
  - `ViewController` 也實作 `WKUIDelegate`（`createWebViewWith`），把網頁用 `target="_blank"` / `window.open()` 開新視窗的請求改成在同一個 WebView 內導覽，避免點了沒反應（`WKWebView` 預設不處理開新視窗請求，不接的話畫面會像卡住）。
    - 例外：App Store 連結（host 為 `apps.apple.com`）不會塞進我們的 WebView，而是直接用 `UIApplication.shared.open()` 交給系統開啟 App Store app。
  - `decidePolicyFor navigationAction` 會檢查目標網址的 scheme，遇到非 `http`/`https` 的 scheme（例如 `itms-apps://`、`itms-appss://` 這類 App Store 深連結，或 `tel:`、`mailto:` 等）一律 `decisionHandler(.cancel)` 並改用 `UIApplication.shared.open()` 交給系統處理。
    - 背景：贊助頁面裡有連到 App Store（`apps.apple.com/.../ipass-money`）的連結，Apple 的網頁版 App Store 頁面本身載入後會自動再導向 `itms-appss://` 想喚起原生 App Store，但 `WKWebView` 無法導覽非 http(s) scheme，沒攔截的話會直接失敗（WebKit 錯誤：`Redirection to URL with a scheme that is not HTTP(S)`，Console 也會看到系統的 `SOAuthorizationCoordinator::tryAuthorize` 相關訊息）。加上這個攔截後，不管連結是不是 App Store，只要目標是非 http(s) scheme 都會直接交給系統處理，不會讓 WebView 嘗試導覽而失敗。
  - 已知系統 log：點擊連結時 Console 可能出現 `SOAuthorizationCoordinator::tryAuthorize (2): Attempting to perform subframe navigation.`，這是系統層級（AuthKit）針對頁面內嵌的第三方 iframe（此頁面含 Facebook Like 外掛的 iframe，以及前述 App Store 連結的自動跳轉）印出的資訊性訊息，本身不是錯誤。
  - ⚠️ 這個贊助頁面是真實金流（歐付寶），實測與除錯時要注意**不要真的按到最終送出付款/選擇付款方式的按鈕**，避免產生非預期的真實交易。
- 已驗證：`xcodegen generate` 可成功產生專案、`build-for-testing` 編譯成功、`run_tests.sh` 執行 Unit + UI 測試皆通過。
- 尚未串接任何 TWQR 相關實際功能（例如掃碼、支付整合等），待需求明確後於本文件補充「功能模組」與對應測試案例。

## 測試

詳見 [docs/TestPlan.md](docs/TestPlan.md)。
