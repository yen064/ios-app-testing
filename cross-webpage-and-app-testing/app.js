(function () {
  "use strict";

  // 對應 apps/cross-webpage-and-ios-app-testing 這個 iOS App 註冊的 URL Scheme。
  var APP_URL_SCHEME = "crosswebapp";

  var openAppButton = document.getElementById("open-app-button");
  var statusEl = document.getElementById("status");

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
