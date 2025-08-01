//
//  CryptoLocalDataSource.swift
//  CryptoCoin
//
//  Created by Janesh Suthar
//

import Foundation
import Domain

public protocol CryptoLocalDataSource: Sendable {
    func fetchCryptoCoins() async throws -> [CryptoCoinEntity]
    func saveCryptoCoins(_ coins: [CryptoCoinEntity]) async throws
}

