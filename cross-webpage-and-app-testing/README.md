# cross-webpage-and-app-testing

搭配 [`apps/cross-webpage-and-ios-app-testing/`](../apps/cross-webpage-and-ios-app-testing/) 這個 iOS App，
測試「Safari 網頁 → 喚起 iOS App → 回到 Safari」的跨網頁與 App 溝通流程。

## 內容

- `cross-webpage-and-app-testing.htm` / `style.css` / `app.js`：純靜態網頁，無建置流程，直接發布即可。
  - 主頁面故意不叫 `index.html`，因為這個資料夾發布到 `gh-pages` 後會跟 `ios-app-testing` repo 本身的 GitHub Pages 共用網址空間，用明確的檔名可以避免跟其他頁面的 `index.html` 混淆，網址也更清楚地指出這是哪個頁面。
- 頁面上的「開啟 App」按鈕會導向 `crosswebapp://open?returnURL=<目前網頁網址>`，
  喚起已安裝的 `cross-webpage-and-ios-app-testing` App；App 內的「回到網頁」按鈕會用
  `canOpenURL` + `openURL` 開回這個 `returnURL`。

## 發布方式（GitHub Pages / gh-pages branch）

本資料夾的內容會發布到 `gh-pages` branch 的根目錄，由 GitHub Pages 服務。

```bash
# 從 repo 根目錄執行，將本資料夾內容部署到 gh-pages branch
git subtree push --prefix cross-webpage-and-app-testing origin gh-pages
```

第一次設定完 `gh-pages` branch 後，需要到 GitHub repo 的 **Settings → Pages**，
把 Source 設定為 `gh-pages` branch（`/ (root)`）。之後網頁會發布在：

```
https://<github-username>.github.io/<repo-name>/cross-webpage-and-app-testing.htm
```

## 本機預覽

```bash
cd cross-webpage-and-app-testing
python3 -m http.server 8000
# 瀏覽器開啟 http://localhost:8000/cross-webpage-and-app-testing.htm
```

注意：Custom URL Scheme 喚起 App 需要在真正的 Safari（模擬器或實機）上測試，
`python3 -m http.server` 起的本機頁面同樣可以測試喚起流程，只是 `returnURL`
會是 `http://localhost:8000/...`，僅適合本機除錯，不適合作為最終要發布驗證的網址。
