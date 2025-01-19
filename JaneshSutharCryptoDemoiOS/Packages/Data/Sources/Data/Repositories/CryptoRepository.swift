//
//  File.swift
//  CryptoCoin
//
//  Created by Janesh Suthar
//

import Foundation
import Domain
public class CryptoRepository: CryptoRepositoryProtocol {
    
    private let networkDataSource: CryptoNetworkDataSource
    private let localDataSource: CryptoLocalDataSource

    public init(networkDataSource: CryptoNetworkDataSource, localDataSource: CryptoLocalDataSource) {
        self.networkDataSource = networkDataSource
        self.localDataSource = localDataSource
    }
    
    public func getCryptoCoinsFromNetwork() async throws -> [CryptoCoinEntity] {
        // Fallback to network if local data is unavailable
        let networkCoins = try await networkDataSource.fetchCryptoCoins()
        try await localDataSource.saveCryptoCoins(networkCoins) // Cache the data
        return networkCoins
    }
    
    public func getCryptoCoinsFromCache() async throws -> [CryptoCoinEntity] {
        // Try local storage first
        let localCoins = try await localDataSource.fetchCryptoCoins()
        return localCoins
    }
    
    public func saveCryptoCoinsIntoCache(_ coins: [CryptoCoinEntity]) async throws {
        try await localDataSource.saveCryptoCoins(coins)
    }
}
