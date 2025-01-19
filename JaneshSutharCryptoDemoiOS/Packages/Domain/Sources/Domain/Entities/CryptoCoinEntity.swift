//
//  CryptoCoinModel.swift
//  CryptoCoin
//
//  Created by Janesh Suthar
//

import Foundation

public struct CryptoCoinEntity: Decodable {
    public let name: String
    public let symbol: String
    public let type: String
    public let isActive: Bool
    public let isNew: Bool
    public let id: String?

    public init(name: String, symbol: String, type: String, isActive: Bool, isNew: Bool, id: String?) {
        self.name = name
        self.symbol = symbol
        self.type = type
        self.isActive = isActive
        self.isNew = isNew
        self.id = id
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case name
        case symbol
        case type
        case isActive = "is_active"
        case isNew = "is_new"
    }
}
