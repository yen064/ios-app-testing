import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    /// App 尚未啟動、由 `crosswebapp://` 冷啟動時會走這裡。
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard scene is UIWindowScene else { return }

        if let url = connectionOptions.urlContexts.first?.url {
            AppLaunchState.shared.pendingURL = url
        }
    }

    /// App 已在背景／前景執行、再被 `crosswebapp://` 喚起時會走這裡。
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        NotificationCenter.default.post(name: .crossWebAppDidReceiveURL, object: nil, userInfo: ["url": url])
    }
}
