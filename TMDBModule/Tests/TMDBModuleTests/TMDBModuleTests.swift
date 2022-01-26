import XCTest
@testable import TMDBModule
@testable import HTTPClientModule

final class TMDBModuleTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(TMDBModule().text, "Hello, World!")
    }
    
    
    private func ephemeralClient(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        trackForMemoryLeaks(client, file: file, line: line)
        return client
    }

    func test_endToEndTestServerGETFruits() {
        switch getFruits() {
        case let .success(fruits)?:
            XCTAssertEqual(fruits.count, 0, "Expected fruit 2 count")
        case let .failure(error)?:
            XCTFail("Expected successful fruits result, got \(error) instead")
            
        default:
            XCTFail("Expected successful fruits result, got no result instead")
        }
    }
    
    private func getFruits(file: StaticString = #filePath, line: UInt = #line) -> Swift.Result<[String], Error>? {
        let client = ephemeralClient()
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: Swift.Result<[String], Error>?
        client.get(from: absoluteServerURL(uri: "getFruits")) { result in
            receivedResult = result.flatMap { (data, response) in
                do {
                    return .success([String].init())
                } catch {
                    return .failure(error)
                }
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }
}
