//
//  GetCryptoCoinsUseCase.swift
//  CryptoCoin
//
//  Created by Janesh Suthar
//

import Foundation

open class FetchCryptoCoinsUseCase {
    private let repository: CryptoRepositoryProtocol

    public init(repository: CryptoRepositoryProtocol) {
        self.repository = repository
    }

    // Fetch data either from network or local based on the flag
    open func execute(fromNetwork: Bool) async throws -> [CryptoCoinEntity] {
        if fromNetwork {
            // Fetch from network and save to local storage
            let networkCoins = try await repository.getCryptoCoinsFromNetwork()
            try await repository.saveCryptoCoinsIntoCache(networkCoins)
            return networkCoins
        } else {
            // Fetch from local storage
            let localCoins = try await repository.getCryptoCoinsFromCache()
            return localCoins
        }
    }
}

