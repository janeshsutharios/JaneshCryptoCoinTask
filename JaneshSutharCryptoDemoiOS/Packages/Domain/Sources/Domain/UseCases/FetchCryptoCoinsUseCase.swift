//
//  FetchCryptoCoinsUseCase.swift
//  CryptoCoin
//
//  Created by Janesh Suthar
//

import Foundation

public protocol FetchCryptoCoinsUseCaseProtocol: Sendable {
    func execute() async throws -> [CryptoCoinEntity]
    func execute(fromNetwork: Bool) async throws -> [CryptoCoinEntity]
}

public actor FetchCryptoCoinsUseCase: FetchCryptoCoinsUseCaseProtocol {
    private let repository: CryptoRepositoryProtocol

    public init(repository: CryptoRepositoryProtocol) {
        self.repository = repository
    }

    /// Fetches crypto coins using the repository's network-first with cache-fallback policy.
    public func execute() async throws -> [CryptoCoinEntity] {
        try await repository.fetchCryptoCoins()
    }

    /// Fetches data explicitly from network or cache; caching is owned by the repository.
    public func execute(fromNetwork: Bool) async throws -> [CryptoCoinEntity] {
        if fromNetwork {
            return try await repository.getCryptoCoinsFromNetwork()
        } else {
            return try await repository.getCryptoCoinsFromCache()
        }
    }
}
