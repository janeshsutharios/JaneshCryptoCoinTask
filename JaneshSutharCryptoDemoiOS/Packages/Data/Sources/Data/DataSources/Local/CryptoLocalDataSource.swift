//
//  CryptoLocalDataSource.swift
//  CryptoCoin
//
//  Created by Janesh Suthar
//

import Foundation
import Domain

public protocol CryptoLocalDataSource {
    func fetchCryptoCoins() async throws -> [CryptoCoinEntity]
    func saveCryptoCoins(_ coins: [CryptoCoinEntity]) async throws
}

