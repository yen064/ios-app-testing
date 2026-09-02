import XCTest

final class CrossWebAppTestingUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppLaunchesAndShowsInitialState() throws {
        let app = XCUIApplication()
        app.launch()

        let label = app.staticTexts["receivedURLLabel"]
        XCTAssertTrue(label.waitForExistence(timeout: 10))

        let returnButton = app.buttons["returnButton"]
        XCTAssertTrue(returnButton.exists)
        XCTAssertFalse(returnButton.isEnabled)
    }
}
