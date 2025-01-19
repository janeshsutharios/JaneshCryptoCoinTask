//
//  CryptoNetworkDataSource.swift
//  CryptoCoin
//
//  Created by Janesh Suthar
//

import Foundation
import Domain
public protocol CryptoNetworkDataSource {
    func fetchCryptoCoins() async throws -> [CryptoCoinEntity]
}
