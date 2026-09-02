import XCTest

final class TWQRAioTestingUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppLaunchesAndShowsWebView() throws {
        let app = XCUIApplication()
        app.launch()

        let webView = app.webViews["webView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10))
    }
}
