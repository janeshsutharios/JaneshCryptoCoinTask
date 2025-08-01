//
//  CryptoNetworkDataSource.swift
//  CryptoCoin
//
//  Created by Janesh Suthar
//

import Foundation
import Domain
public protocol CryptoNetworkDataSource: Sendable {
    func fetchCryptoCoins() async throws -> [CryptoCoinEntity]
}
