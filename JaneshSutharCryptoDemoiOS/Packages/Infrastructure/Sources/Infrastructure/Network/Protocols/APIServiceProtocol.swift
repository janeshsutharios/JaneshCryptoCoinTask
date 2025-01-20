//
//  NewsRepositoryProtocol.swift
//
//  Created by Janesh Suthar.
//

import Foundation
import Domain

public protocol APIServiceProtocol {
    func fetchCryptoCoins() async throws -> [CryptoCoinEntity]
}
