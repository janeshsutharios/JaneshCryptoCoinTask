//
//  GetCryptoCoinsUseCaseTests.swift
//  CryptoCoinTests
//
//  Created by Janesh Suthar
//

import XCTest
@testable import Domain

public final class GetCryptoCoinsUseCaseTests: XCTestCase {

    public var useCase: FetchCryptoCoinsUseCase!
    public var mockRepository: MockCryptoRepository!

    public override func setUp() {
        super.setUp()
        mockRepository = MockCryptoRepository()
        useCase = FetchCryptoCoinsUseCase(repository: mockRepository)
    }

    public override func tearDown() {
        useCase = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Default Execute (Network-First + Cache Fallback)
    func testExecuteDefault_returnsNetworkCoinsAndCachesOnce() async throws {
        let mockCoins = [CryptoCoinEntity(name: "Bitcoin", symbol: "BTC", type: "coin", isActive: true, isNew: true, id: "btc-bitcoin")]
        mockRepository.networkCoins = mockCoins

        let coins = try await useCase.execute()

        XCTAssertEqual(coins.count, 1)
        XCTAssertEqual(coins.first?.name, "Bitcoin")
        XCTAssertEqual(mockRepository.saveCallCount, 1)
    }

    func testExecuteDefault_fallsBackToCacheOnNetworkFailure() async throws {
        mockRepository.errorToThrow = NSError(domain: "Network", code: -1009)
        mockRepository.localCoins = [CryptoCoinEntity(name: "Ethereum", symbol: "ETH", type: "coin", isActive: true, isNew: false, id: "eth-ethereum")]

        let coins = try await useCase.execute()

        XCTAssertEqual(coins.count, 1)
        XCTAssertEqual(coins.first?.symbol, "ETH")
    }

    // MARK: - Explicit Network & Local Tests
    func testExecuteNetworkSuccess_doesNotDoubleSave() async throws {
        let mockCoins = [CryptoCoinEntity(name: "Bitcoin", symbol: "BTC", type: "coin", isActive: true, isNew: true, id: UUID().uuidString)]
        mockRepository.networkCoins = mockCoins

        let coins = try await useCase.execute(fromNetwork: true)

        XCTAssertEqual(coins.count, 1)
        XCTAssertEqual(coins.first?.name, "Bitcoin")
        XCTAssertEqual(mockRepository.saveCallCount, 0, "UseCase should not perform a duplicate save; repository owns caching")
    }

    func testExecuteNetworkFailure() async throws {
        mockRepository.errorToThrow = NSError(domain: "MockRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Network data not available"])

        await assertThrowsError({
            _ = try await self.useCase.execute(fromNetwork: true)
        }, errorDescription: "Network data not available")
    }

    func testExecuteLocalSuccess() async throws {
        let mockCoins = [CryptoCoinEntity(name: "Ethereum", symbol: "ETH", type: "coin", isActive: false, isNew: false, id: UUID().uuidString)]
        mockRepository.localCoins = mockCoins

        let coins = try await useCase.execute(fromNetwork: false)

        XCTAssertEqual(coins.count, 1)
        XCTAssertEqual(coins.first?.name, "Ethereum")
    }

    func testExecuteLocalFailure() async throws {
        mockRepository.errorToThrow = NSError(domain: "MockRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Local data not available"])

        await assertThrowsError({
            _ = try await self.useCase.execute(fromNetwork: false)
        }, errorDescription: "Local data not available")
    }

    // MARK: - Helper
    private func assertThrowsError(_ expression: @escaping () async throws -> Void, errorDescription: String) async {
        do {
            try await expression()
            XCTFail("Expected error but none was thrown.")
        } catch let error as NSError {
            XCTAssertEqual(error.localizedDescription, errorDescription)
        }
    }
}
