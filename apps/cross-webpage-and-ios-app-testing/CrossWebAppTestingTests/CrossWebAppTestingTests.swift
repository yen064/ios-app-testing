import XCTest
@testable import CrossWebAppTesting

final class CrossWebAppTestingTests: XCTestCase {

    func testViewControllerLoadsWithoutCrashing() {
        let viewController = ViewController()
        viewController.loadViewIfNeeded()
        XCTAssertNotNil(viewController.view)
    }
}
