//
//  NewsRepositoryProtocol.swift
//
//  Created by Janesh Suthar.
//

import Foundation
import Domain

public protocol APIServiceProtocol: Sendable {
    func fetchCryptoCoins() async throws -> [CryptoCoinEntity]
}
