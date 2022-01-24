//
//  File.swift
//  
//
//  Created by Muzammil Peer on 24/01/2022.
//

import XCTest
import HTTPClientModule

class HTTPClientEndtoEndTests: XCTestCase {
    private var baseURL: URL {
        return URL(string: "https://7a94e1a1-0a1e-4f44-b281-878ad929c059.mock.pstmn.io/")!
    }
    private func absoluteServerURL(uri:String) -> URL {
        return URL(string: "\(baseURL.absoluteString)\(uri)")!
    }
    private func ephemeralClient(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        trackForMemoryLeaks(client, file: file, line: line)
        return client
    }

    func test_endToEndTestServerGETFruits() {
        switch getFruits() {
        case let .success(fruits)?:
            XCTAssertEqual(fruits.count, 2, "Expected fruit 2 count")
        case let .failure(error)?:
            XCTFail("Expected successful fruits result, got \(error) instead")
            
        default:
            XCTFail("Expected successful fruits result, got no result instead")
        }
    }
    
    func test_endToEndTestServerPOSTFruit() {
        switch createFruit() {
        case let .success(fruits)?:
            XCTAssertEqual(fruits.errorCode, "0", "Expected success response")
        case let .failure(error)?:
            XCTFail("Expected successful fruit result, got \(error) instead")
            
        default:
            XCTFail("Expected successful fruit result, got no result instead")
        }
    }
    
    func test_endToEndTestServerPutFruit() {
        switch updateFruit() {
        case let .success(fruits)?:
            XCTAssertEqual(fruits.errorCode, "0", "Expected success response")
        case let .failure(error)?:
            XCTFail("Expected successful fruit result, got \(error) instead")
            
        default:
            XCTFail("Expected successful fruit result, got no result instead")
        }
    }
    func test_endToEndTestServerDeleteFruit() {
        switch deleteFruit() {
        case let .success(fruits)?:
            XCTAssertEqual(fruits.errorCode, "0", "Expected success response")
        case let .failure(error)?:
            XCTFail("Expected successful fruit result, got \(error) instead")
            
        default:
            XCTFail("Expected successful fruit result, got no result instead")
        }
    }
    
}
extension HTTPClientEndtoEndTests
{
    private func imageURL(at index: Int) -> URL {
        return URL(string: "https://url-\(index+1).com")!
    }
    
   
    private func getFruits(file: StaticString = #filePath, line: UInt = #line) -> Swift.Result<[StubFruitImage], Error>? {
        let client = ephemeralClient()
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: Swift.Result<[StubFruitImage], Error>?
        client.get(from: absoluteServerURL(uri: "getFruits")) { result in
            receivedResult = result.flatMap { (data, response) in
                do {
                    return .success(try StubFruitItemsMapper<[RemoteFruitItem]>.map(data, from: response))
                } catch {
                    return .failure(error)
                }
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }
    
    private func createFruit(file: StaticString = #filePath, line: UInt = #line) -> Swift.Result<Root, Error>? {
        let client = ephemeralClient()
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: Swift.Result<Root, Error>?
        let item:RemoteFruitItem = RemoteFruitItem.init(id: nil, name: "Orange", color: "orange", image: nil)
        
        client.post(from: absoluteServerURL(uri: "createFruit"), codableRequestBody: item) { result in
            receivedResult = result.flatMap { (data, response) in
                do {
                    return .success(try StubFruitItemsMapper<Root>.validate(data, from: response))
                } catch {
                    return .failure(error)
                }
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }
    
    private func updateFruit(file: StaticString = #filePath, line: UInt = #line) -> Swift.Result<Root, Error>? {
        let client = ephemeralClient()
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: Swift.Result<Root, Error>?
        let item:RemoteFruitItem = RemoteFruitItem.init(id: nil, name: "Orange", color: "orange", image: nil)
        
        client.put(from: absoluteServerURL(uri: "updateFruit"), codableRequestBody: item) { result in
            receivedResult = result.flatMap { (data, response) in
                do {
                    return .success(try StubFruitItemsMapper<Root>.validate(data, from: response))
                } catch {
                    return .failure(error)
                }
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }
    private func deleteFruit(file: StaticString = #filePath, line: UInt = #line) -> Swift.Result<Root, Error>? {
        let client = ephemeralClient()
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: Swift.Result<Root, Error>?
        let item:RemoteFruitItem = RemoteFruitItem.init(id: nil, name: "Orange", color: "orange", image: nil)
        
        client.delete(from: absoluteServerURL(uri: "deleteFruit"), codableRequestBody: item) { result in
            receivedResult = result.flatMap { (data, response) in
                do {
                    return .success(try StubFruitItemsMapper<Root>.validate(data, from: response))
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
