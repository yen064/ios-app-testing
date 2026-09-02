import XCTest
@testable import TWQRAioTesting

final class TWQRAioTestingTests: XCTestCase {

    func testViewControllerLoadsWithoutCrashing() {
        let viewController = ViewController()
        viewController.loadViewIfNeeded()
        XCTAssertNotNil(viewController.view)
    }
}
