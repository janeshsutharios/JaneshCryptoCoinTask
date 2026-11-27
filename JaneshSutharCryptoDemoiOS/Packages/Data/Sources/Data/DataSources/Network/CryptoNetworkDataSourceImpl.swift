//
//  CryptoNetworkDataSourceImpl.swift
//  CryptoCoin
//
//  Created by Janesh Suthar
//

import Foundation
import Domain
import Common
import Infrastructure

public actor CryptoNetworkDataSourceImpl: CryptoNetworkDataSource {
    private let apiService: any APIServiceProtocol

    public init(apiService: any APIServiceProtocol) {
        self.apiService = apiService
    }

    public func fetchCryptoCoins() async throws -> [CryptoCoinEntity] {
        return try await apiService.fetchCryptoCoins()
    }
}
