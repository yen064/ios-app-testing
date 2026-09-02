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
