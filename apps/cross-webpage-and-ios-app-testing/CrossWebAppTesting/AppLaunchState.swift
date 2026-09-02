import Foundation

/// 冷啟動時 SceneDelegate 收到的 `crosswebapp://` URL 會先存在這裡，
/// 因為這時 ViewController 的 view 還沒建立、還沒訂閱通知，直接送 Notification 會漏接。
final class AppLaunchState {

    static let shared = AppLaunchState()

    private init() {}

    var pendingURL: URL?
}
