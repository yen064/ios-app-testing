import XCTest

final class TWQRAioTestingUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppLaunchesAndShowsTitle() throws {
        let app = XCUIApplication()
        app.launch()

        let titleLabel = app.staticTexts["titleLabel"]
        XCTAssertTrue(titleLabel.waitForExistence(timeout: 5))
    }
}
