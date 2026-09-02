import UIKit
import WebKit
import os.log

final class ViewController: UIViewController {

    private let targetURL = URL(string: "https://payment.opay.tw/Broadcaster/Donate/BCEC3D3E9315EC70510820E500B7B587")!

    private let log = Logger(subsystem: "com.aaronyen.twqraiotesting", category: "WebView")

    private let webView: WKWebView = {
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.accessibilityIdentifier = "webView"
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        webView.load(URLRequest(url: targetURL))
    }
}

extension ViewController: WKNavigationDelegate {

    /// 使用者在畫面上點擊連結（或任何觸發導覽的動作）時會先進到這裡，
    /// 可以在放行前看到目標網址、導覽類型等資訊。
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        let url = navigationAction.request.url?.absoluteString ?? "(no url)"
        log.info("navigationAction: type=\(navigationAction.navigationType.rawValue, privacy: .public) url=\(url, privacy: .public)")

        // itms-apps:// / itms-appss:// / tel:／mailto: 等非 http(s) scheme（例如 App Store 深連結）
        // WKWebView 無法自己導覽，要交給系統處理，不能塞進 WebView 裡。
        if let requestURL = navigationAction.request.url,
           let scheme = requestURL.scheme?.lowercased(),
           scheme != "http", scheme != "https" {
            log.info("non-http(s) scheme, handing off to system: \(requestURL.absoluteString, privacy: .public)")
            if UIApplication.shared.canOpenURL(requestURL) {
                UIApplication.shared.open(requestURL)
            }
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        log.info("didStartProvisionalNavigation url=\(webView.url?.absoluteString ?? "(no url)", privacy: .public)")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        log.info("didFinish url=\(webView.url?.absoluteString ?? "(no url)", privacy: .public)")
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        log.error("didFail url=\(webView.url?.absoluteString ?? "(no url)", privacy: .public) error=\(error.localizedDescription, privacy: .public)")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        log.error("didFailProvisionalNavigation url=\(webView.url?.absoluteString ?? "(no url)", privacy: .public) error=\(error.localizedDescription, privacy: .public)")
    }
}

extension ViewController: WKUIDelegate {

    /// 網頁用 `target="_blank"` 或 `window.open()` 要求開新視窗時會進到這裡。
    /// 沒有實作這個方法的話，WKWebView 會直接忽略請求，畫面看起來就像點了沒反應。
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        guard let requestURL = navigationAction.request.url else { return nil }
        log.info("createWebViewWith (new window request) url=\(requestURL.absoluteString, privacy: .public)")

        // App Store 連結不塞進我們自己的 WebView（那個頁面之後一定會再導向 itms-appss:// 導致失敗），
        // 直接交給系統開啟 App Store app。
        if requestURL.host?.hasSuffix("apps.apple.com") == true {
            UIApplication.shared.open(requestURL)
            return nil
        }

        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
