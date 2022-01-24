//
//  StubFruitImage.swift
//  
//
//  Created by Muzammil Peer on 24/01/2022.
//
import Foundation

public struct StubFruitImage: Hashable {
    public let id: UUID?
    public let name: String?
    public let color: String?
    public let url: URL?
    
    public init(id: UUID?, name: String?, color: String?, url: URL?) {
        self.id = id
        self.name = name
        self.color = color
        self.url = url
    }
}
