//
//  MockCryptoCoinsRepository.swift
//  CryptoCoinTests
//
//  Created by Janesh Suthar
//

import Foundation
import Domain
import Data
import Infrastructure

@testable import Presentation

// Mock implementation of the FetchCryptoCoinsUseCase
class MockGetCryptoCoinsUseCase: FetchCryptoCoinsUseCase {
    
    var mockedCoins: [CryptoCoinEntity] = []  // Coins to return from the mock
    var errorToThrow: Error?  // Error to throw in case of failure
    var fromNetworkFlag: Bool?  // Flag to simulate network or local fetching
    
    // Mocked repository
    private var mockRepository: MockCryptoRepository!
    
    // Initialize with a mocked repository
    override init(repository: CryptoRepositoryProtocol) {
        self.mockRepository = repository as? MockCryptoRepository
        super.init(repository: repository)
    }
    
    // Override execute method to return mock data
    override func execute(fromNetwork: Bool) async throws -> [CryptoCoinEntity] {
        self.fromNetworkFlag = fromNetwork
        
        // Simulate an error if errorToThrow is set
        if let error = errorToThrow {
            throw error
        }
        
        // Return predefined mock coins
        return mockedCoins
    }
}

