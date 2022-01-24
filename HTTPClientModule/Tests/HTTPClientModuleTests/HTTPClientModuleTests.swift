import XCTest
@testable import HTTPClientModule

final class HTTPClientModuleTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(HTTPClientModule().text, "Hello, World!")
    }
}
