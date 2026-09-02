import UIKit

extension Notification.Name {
    static let crossWebAppDidReceiveURL = Notification.Name("crossWebAppDidReceiveURL")
}

final class ViewController: UIViewController {

    private var returnURL: URL?

    private let receivedURLLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15)
        label.accessibilityIdentifier = "receivedURLLabel"
        label.text = "尚未從網頁開啟"
        return label
    }()

    private let returnButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("回到網頁", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.accessibilityIdentifier = "returnButton"
        button.isEnabled = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(receivedURLLabel)
        view.addSubview(returnButton)

        NSLayoutConstraint.activate([
            receivedURLLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -32),
            receivedURLLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            receivedURLLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),

            returnButton.topAnchor.constraint(equalTo: receivedURLLabel.bottomAnchor, constant: 32),
            returnButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        returnButton.addTarget(self, action: #selector(returnButtonTapped), for: .touchUpInside)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveOpenURL(_:)),
            name: .crossWebAppDidReceiveURL,
            object: nil
        )

        if let launchURL = AppLaunchState.shared.pendingURL {
            AppLaunchState.shared.pendingURL = nil
            handle(url: launchURL)
        }
    }

    @objc private func didReceiveOpenURL(_ notification: Notification) {
        guard let url = notification.userInfo?["url"] as? URL else { return }
        handle(url: url)
    }

    /// 網頁呼叫 `crosswebapp://open?returnURL=<原網頁網址>` 時解析出 returnURL，
    /// 讓「回到網頁」按鈕知道要開回哪個網址（而不是寫死一個固定網址）。
    private func handle(url: URL) {
        receivedURLLabel.text = "已從網頁開啟：\n\(url.absoluteString)"

        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let returnURLString = components.queryItems?.first(where: { $0.name == "returnURL" })?.value,
            let returnURL = URL(string: returnURLString)
        else {
            return
        }

        self.returnURL = returnURL
        returnButton.isEnabled = true
    }

    @objc private func returnButtonTapped() {
        guard let returnURL else { return }
        if UIApplication.shared.canOpenURL(returnURL) {
            UIApplication.shared.open(returnURL)
        }
    }
}
