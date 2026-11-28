//
//  MockCryptoRepository.swift
//  CryptoCoinTests
//
//  Created by Janesh Suthar.
//

import Foundation
import Domain

public final class MockCryptoRepository: CryptoRepositoryProtocol, @unchecked Sendable {
    public var networkCoins: [CryptoCoinEntity] = []
    public var localCoins: [CryptoCoinEntity] = []
    public var errorToThrow: (any Error)?
    public var saveCallCount = 0
    public var networkCallCount = 0
    public var cacheCallCount = 0

    public init() {}

    public func fetchCryptoCoins() async throws -> [CryptoCoinEntity] {
        do {
            let coins = try await getCryptoCoinsFromNetwork()
            try await saveCryptoCoinsIntoCache(coins)
            return coins
        } catch {
            if !localCoins.isEmpty {
                return try await getCryptoCoinsFromCache()
            }
            throw error
        }
    }

    public func getCryptoCoinsFromNetwork() async throws -> [CryptoCoinEntity] {
        networkCallCount += 1
        if let error = errorToThrow {
            throw error
        }
        return networkCoins
    }

    public func saveCryptoCoinsIntoCache(_ coins: [CryptoCoinEntity]) async throws {
        saveCallCount += 1
        localCoins = coins
    }

    public func getCryptoCoinsFromCache() async throws -> [CryptoCoinEntity] {
        cacheCallCount += 1
        if let error = errorToThrow, localCoins.isEmpty {
            throw error
        }
        return localCoins
    }
}
