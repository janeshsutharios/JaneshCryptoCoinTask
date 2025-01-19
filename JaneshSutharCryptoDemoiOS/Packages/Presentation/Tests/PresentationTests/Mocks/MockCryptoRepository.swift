//
//  MockCryptoRepository.swift
//  CryptoCoinTests
//
//  Created by Janesh Suthar.
//
import Foundation
import Domain
import Data
import Infrastructure
@testable import Presentation
// Mock repository class
public class MockCryptoRepository: CryptoRepositoryProtocol {
    
    public var networkCoins: [CryptoCoinEntity] = []
    public var localCoins: [CryptoCoinEntity] = []
    public var errorToThrow: Error?
    public init() {}
    
    // Mock fetching coins from network
    public func getCryptoCoinsFromNetwork() async throws -> [CryptoCoinEntity] {
        if let error = errorToThrow {
            throw error
        }
        return networkCoins
    }
    
    // Mock saving coins into local storage
    public func saveCryptoCoinsIntoCache(_ coins: [CryptoCoinEntity]) async throws {
        // Simulate saving coins (no-op in mock)
        localCoins = coins
    }
    
    // Mock fetching coins from local storage
    public func getCryptoCoinsFromCache() async throws -> [CryptoCoinEntity] {
        if let error = errorToThrow {
            throw error
        }
        return localCoins
    }
}
