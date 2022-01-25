//
//  File.swift
//  
//
//  Created by Muzammil Peer on 24/01/2022.
//

import XCTest
import HTTPClientModule

class HTTPClientEndtoEndTests: XCTestCase {

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
    
    func test_endToEndTestServerPOSTFruitSuccess() {
        switch createFruit() {
        case let .success(fruits)?:
            XCTAssertEqual(fruits.errorCode, "0", "Expected success response")
        case let .failure(error)?:
            XCTFail("Expected successful fruit result, got \(error) instead")
            
        default:
            XCTFail("Expected successful fruit result, got no result instead")
        }
    }
    
    func test_endToEndTestServerPOSTFruitWithError() {
        switch createFruit(errorCode:"404",errorMessage:"error Message") {
        case let .success(fruits)?:
            XCTAssertEqual(fruits.errorCode, "404", "Expected success response")
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
    func test_endToEndTestServerUploadFruitImage() {
        switch uploadFruitImage() {
        case let .success(fruits)?:
            XCTAssertEqual(fruits.errorCode, "0", "Expected success response")
        case let .failure(error)?:
            XCTFail("Expected successful fruit result, got \(error) instead")
            
        default:
            XCTFail("Expected successful fruit result, got no result instead")
        }
    }
    
    func test_endToEndTestServerUploadFruitImageMultiPart() {
        switch uploadFruitImageMultiPart() {
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
    
    private func createFruit(errorCode:String?="0",errorMessage:String?="success",file: StaticString = #filePath, line: UInt = #line) -> Swift.Result<Root, Error>? {
        let client = ephemeralClient()
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: Swift.Result<Root, Error>?
        
        client.post(from: absoluteServerURL(uri: "createFruit").appendingPathComponent(errorCode ?? "").appendingPathComponent(errorMessage ?? ""), codableRequestBody: anyFruitItem) { result in
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
    
    private func updateFruit(errorCode:String?="0",errorMessage:String?="success",file: StaticString = #filePath, line: UInt = #line) -> Swift.Result<Root, Error>? {
        let client = ephemeralClient()
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: Swift.Result<Root, Error>?
        
        client.put(from: absoluteServerURL(uri: "updateFruit").appendingPathComponent(errorCode ?? "").appendingPathComponent(errorMessage ?? ""), codableRequestBody: anyFruitItem) { result in
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
    private func deleteFruit(errorCode:String?="0",errorMessage:String?="success",file: StaticString = #filePath, line: UInt = #line) -> Swift.Result<Root, Error>? {
        let client = ephemeralClient()
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: Swift.Result<Root, Error>?
        
        client.delete(from: absoluteServerURL(uri: "deleteFruit").appendingPathComponent(errorCode ?? "").appendingPathComponent(errorMessage ?? ""), codableRequestBody: anyFruitItem) { result in
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
    
    private func uploadFruitImage(errorCode:String?="0",errorMessage:String?="success",file: StaticString = #filePath, line: UInt = #line) -> Swift.Result<Root, Error>? {
        let client = ephemeralClient()
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: Swift.Result<Root, Error>?
        
        client.postMultiPartFile(from: absoluteServerURL(uri: "uploadFruitImage").appendingPathComponent(errorCode ?? "").appendingPathComponent(errorMessage ?? ""), fileURL: anyLocalFileURL) { result in
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
    
    private func uploadFruitImageMultiPart(errorCode:String?="0",errorMessage:String?="success",file: StaticString = #filePath, line: UInt = #line) -> Swift.Result<Root, Error>? {
        let client = ephemeralClient()
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: Swift.Result<Root, Error>?
        let localFileBinaryData = try! Data(contentsOf: anyLocalFileURL)

      
        client.postMultiPartData(from: absoluteServerURL(uri: "uploadFruitImage").appendingPathComponent(errorCode ?? "").appendingPathComponent(errorMessage ?? ""), binaryData: localFileBinaryData, codableRequestBody: anyFruitItem) { result in
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
