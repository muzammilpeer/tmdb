//
//  StubFruitItemsMapper.swift
//  
//
//  Created by Muzammil Peer on 24/01/2022.
//

import Foundation

public final class StubFruitItemsMapper<T:Decodable> {

  
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
//    public static func validate<T:Decodable>(decodable:T, _ data: Data, from response: HTTPURLResponse) throws -> T{
    public static func validate(_ data: Data, from response: HTTPURLResponse) throws -> T{
        guard response.isOK, let root = try? JSONDecoder().decode(T.self, from: data) else {
            throw Error.invalidData
        }
        return root
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [StubFruitImage] {
        
        do {
            let decoder = JSONDecoder()
            let messages = try decoder.decode(Root.self, from: data)
            print(messages as Any)
        } catch DecodingError.dataCorrupted(let context) {
            print(context)
        } catch DecodingError.keyNotFound(let key, let context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch DecodingError.valueNotFound(let value, let context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch DecodingError.typeMismatch(let type, let context) {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw Error.invalidData
        }
        
        return root.fruits
    }
}


public struct Root: Decodable {
    private let items: [RemoteFruitItem]
    public let errorCode : String?
    public let message : String?

   
    var fruits: [StubFruitImage] {
        items.map { StubFruitImage(id: $0.id, name: $0.name, color: $0.color, url: $0.image) }
    }
    enum CodingKeys: String, CodingKey {
        case items = "items"
        case errorCode = "errorCode"
        case message = "message"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        items = try values.decodeIfPresent([RemoteFruitItem].self, forKey: .items) ?? []
        errorCode = try values.decodeIfPresent(String.self, forKey: .errorCode)
        message = try values.decodeIfPresent(String.self, forKey: .message)
    }
}

public struct RemoteFruitItem: Codable {
    let id: UUID?
    let name: String?
    let color: String?
    let image: URL?
}
