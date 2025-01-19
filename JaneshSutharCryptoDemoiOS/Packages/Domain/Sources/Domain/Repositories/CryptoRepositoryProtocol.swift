//
//  CryptoRepositoryProtocol.swift
//  CryptoCoin
//
//  Created by Janesh Suthar
//

import Foundation

public protocol CryptoRepositoryProtocol {
    func getCryptoCoinsFromNetwork() async throws -> [CryptoCoinEntity]
    func getCryptoCoinsFromCache() async throws -> [CryptoCoinEntity]
    func saveCryptoCoinsIntoCache(_ coins: [CryptoCoinEntity]) async throws
}

