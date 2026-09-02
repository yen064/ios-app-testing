# ios-app-testing

這是一個 **monorepo**，用來存放多個 iOS app 專案及其測試。每個 app 各自獨立，放在 `apps/<app-name>/` 底下。

## Repo 結構

```
ios-app-testing/
├── CLAUDE.md              ← 本檔案：repo 層級規範
├── .gitignore
└── apps/
    └── <app-name>/
        ├── CLAUDE.md              ← app 層級規範與決策記錄
        ├── project.yml            ← XcodeGen 專案定義（唯一真實來源）
        ├── <AppName>.xcodeproj    ← 由 XcodeGen 產生，不進版控
        ├── <AppName>/             ← app 原始碼
        ├── <AppName>Tests/        ← Unit tests
        ├── <AppName>UITests/      ← UI tests
        ├── Scripts/
        │   ├── generate_project.sh
        │   └── run_tests.sh
        └── docs/
            └── TestPlan.md        ← 測試計劃與測試案例追蹤表
```

## 核心決策

1. **每個 app 一個資料夾，放在 `apps/` 底下**。app 名稱使用 kebab-case（如 `twqr-aio-testing`），Xcode target/scheme 名稱使用對應的 PascalCase。
2. **用 XcodeGen 產生 `.xcodeproj`**，而非手動維護或手刻 `project.pbxproj`。
   - 原因：`.xcodeproj` 的 XML/plist 格式難以手動編輯與 code review，容易產生衝突或損毀；`project.yml` 是純文字、易讀、易 diff。
   - 規則：**`.xcodeproj` 不進版控**（見 `.gitignore`），每次 clone 或修改 `project.yml` / 新增檔案後，都要執行該 app 的 `Scripts/generate_project.sh` 重新產生。
3. **UI 框架依各 app 需求決定**，並記錄在該 app 的 `CLAUDE.md` 中（見下方各 app 章節）。不假設所有 app 都用同一套框架。
4. **每個 app 都要有 `docs/TestPlan.md`**，記錄測試範圍、自動化測試執行方式，以及測試案例追蹤表（案例 ID、狀態、對應自動化測試或手動測試）。
5. **每個 app 都要有 `Scripts/generate_project.sh` 與 `Scripts/run_tests.sh`**，讓專案產生與測試執行可以一致地重現，不依賴人工在 Xcode GUI 內操作。

## 新增一個 app 時的標準流程

1. 在 `apps/` 下建立 `<app-name>/` 資料夾。
2. 撰寫 `project.yml`（用 XcodeGen 語法定義 target、scheme、bundle id、deployment target 等）。
3. 建立原始碼目錄、Tests 目錄、UITests 目錄。
4. 建立 `Scripts/generate_project.sh`、`Scripts/run_tests.sh`（可參考現有 app 複製修改）。
5. 建立 `docs/TestPlan.md`。
6. 建立該 app 專屬的 `CLAUDE.md`，記錄此 app 特有的技術決策（UI 框架、最低版本、bundle id 規則、預設模擬器等）。
7. 執行 `xcodegen generate`（或 `Scripts/generate_project.sh`）產生 `.xcodeproj`，並跑一次 `Scripts/run_tests.sh` 確認骨架可編譯、測試可執行。
8. 回到本檔案的「已建立的 app」清單補上一筆。

## 已建立的 App

| App | 資料夾 | 平台 | UI 框架 | 說明 |
|---|---|---|---|---|
| TWQR AIO Testing | `apps/twqr-aio-testing/` | iOS (iPhone) | UIKit | 詳見 [apps/twqr-aio-testing/CLAUDE.md](apps/twqr-aio-testing/CLAUDE.md) |
| Cross Web App Testing | `apps/cross-webpage-and-ios-app-testing/` | iOS (iPhone) | UIKit | 搭配 [`cross-webpage-and-app-testing/`](cross-webpage-and-app-testing/) 網頁測試跨網頁與 App 溝通流程，詳見 [apps/cross-webpage-and-ios-app-testing/CLAUDE.md](apps/cross-webpage-and-ios-app-testing/CLAUDE.md) |

## 環境需求

- Xcode（本機測試時為 Xcode 26.3）
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)：`brew install xcodegen`
- （選用）[xcbeautify](https://github.com/tuist/xcbeautify)：讓 `xcodebuild` 輸出更易讀，`run_tests.sh` 會自動偵測是否存在並使用
