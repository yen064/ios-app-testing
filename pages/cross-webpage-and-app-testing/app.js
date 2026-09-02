(function () {
  "use strict";

  // 對應 apps/cross-webpage-and-ios-app-testing 這個 iOS App 註冊的 URL Scheme。
  var APP_URL_SCHEME = "crosswebapp";

  var openAppButton = document.getElementById("open-app-button");
  var statusEl = document.getElementById("status");
  var timerEl = document.getElementById("timer");

  // 每秒 +1，單純用來驗證從 App 回到 Safari 後這個頁面是不是還活著（同一個 JS 狀態延續），
  // 而不是被系統重新載入了一份新的頁面。
  var elapsedSeconds = 0;
  setInterval(function () {
    elapsedSeconds += 1;
    timerEl.textContent = String(elapsedSeconds);
  }, 1000);

  function buildAppURL() {
    var returnURL = window.location.href;
    return APP_URL_SCHEME + "://open?returnURL=" + encodeURIComponent(returnURL);
  }

  function openApp() {
    statusEl.textContent = "正在嘗試開啟 App…";
    window.location.href = buildAppURL();
  }

  openAppButton.addEventListener("click", openApp);
})();
