//
//  CryptoRepository.swift
//  CryptoCoin
//
//  Created by Janesh Suthar
//

import Foundation
import Domain

public actor CryptoRepository: CryptoRepositoryProtocol {

    private let networkDataSource: any CryptoNetworkDataSource
    private let localDataSource: any CryptoLocalDataSource

    public init(networkDataSource: any CryptoNetworkDataSource, localDataSource: any CryptoLocalDataSource) {
        self.networkDataSource = networkDataSource
        self.localDataSource = localDataSource
    }

    /// Attempts network fetch (caching once on success) and falls back to local cache if network fails.
    public func fetchCryptoCoins() async throws -> [CryptoCoinEntity] {
        do {
            return try await getCryptoCoinsFromNetwork()
        } catch {
            if let cachedCoins = try? await getCryptoCoinsFromCache(), !cachedCoins.isEmpty {
                return cachedCoins
            }
            throw error
        }
    }

    public func getCryptoCoinsFromNetwork() async throws -> [CryptoCoinEntity] {
        let networkCoins = try await networkDataSource.fetchCryptoCoins()
        try await localDataSource.saveCryptoCoins(networkCoins)
        return networkCoins
    }

    public func getCryptoCoinsFromCache() async throws -> [CryptoCoinEntity] {
        try await localDataSource.fetchCryptoCoins()
    }

    public func saveCryptoCoinsIntoCache(_ coins: [CryptoCoinEntity]) async throws {
        try await localDataSource.saveCryptoCoins(coins)
    }
}
