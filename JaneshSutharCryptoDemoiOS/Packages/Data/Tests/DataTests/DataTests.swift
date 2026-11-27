import XCTest
import CoreData
import Domain
import Infrastructure
@testable import Data

// MARK: - Mocks
final class MockNetworkDataSource: CryptoNetworkDataSource, @unchecked Sendable {
    var coinsToReturn: [CryptoCoinEntity] = []
    var errorToThrow: (any Error)?
    var fetchCallCount = 0

    func fetchCryptoCoins() async throws -> [CryptoCoinEntity] {
        fetchCallCount += 1
        if let errorToThrow { throw errorToThrow }
        return coinsToReturn
    }
}

final class MockLocalDataSource: CryptoLocalDataSource, @unchecked Sendable {
    var storedCoins: [CryptoCoinEntity] = []
    var fetchError: (any Error)?
    var saveError: (any Error)?
    var saveCallCount = 0

    func fetchCryptoCoins() async throws -> [CryptoCoinEntity] {
        if let fetchError { throw fetchError }
        return storedCoins
    }

    func saveCryptoCoins(_ coins: [CryptoCoinEntity]) async throws {
        saveCallCount += 1
        if let saveError { throw saveError }
        storedCoins = coins
    }
}

final class MockAPIService: APIServiceProtocol, @unchecked Sendable {
    var coins: [CryptoCoinEntity] = []
    var errorToThrow: (any Error)?

    func fetchCryptoCoins() async throws -> [CryptoCoinEntity] {
        if let errorToThrow { throw errorToThrow }
        return coins
    }
}

// MARK: - Tests
final class DataTests: XCTestCase {

    private var coreDataHelper: CoreDataHelper!
    private var localDataSource: CryptoLocalDataSourceImpl!

    override func setUp() async throws {
        try await super.setUp()
        coreDataHelper = try CoreDataHelper(inMemory: true)
        localDataSource = CryptoLocalDataSourceImpl(coreDataHelper: coreDataHelper)
    }

    override func tearDown() {
        localDataSource = nil
        coreDataHelper = nil
        super.tearDown()
    }

    // MARK: - Local Data Source Tests
    func testSaveAndFetch_preservesCoinPropertiesAndID() async throws {
        let coin = CryptoCoinEntity(name: "Bitcoin", symbol: "BTC", type: "coin", isActive: true, isNew: false, id: "btc-bitcoin")
        try await localDataSource.saveCryptoCoins([coin])

        let fetched = try await localDataSource.fetchCryptoCoins()
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.id, "btc-bitcoin")
        XCTAssertEqual(fetched.first?.name, "Bitcoin")
        XCTAssertEqual(fetched.first?.symbol, "BTC")
        XCTAssertEqual(fetched.first?.type, "coin")
        XCTAssertEqual(fetched.first?.isActive, true)
        XCTAssertEqual(fetched.first?.isNew, false)
    }

    func testSaveRepeatedly_replacesOldEntriesAndUpdatesMainContext() async throws {
        let initial = [
            CryptoCoinEntity(name: "Bitcoin", symbol: "BTC", type: "coin", isActive: true, isNew: false, id: "btc"),
            CryptoCoinEntity(name: "Ethereum", symbol: "ETH", type: "coin", isActive: true, isNew: false, id: "eth")
        ]
        try await localDataSource.saveCryptoCoins(initial)
        let firstFetch = try await localDataSource.fetchCryptoCoins()
        XCTAssertEqual(firstFetch.count, 2)

        let replacement = [
            CryptoCoinEntity(name: "Solana", symbol: "SOL", type: "coin", isActive: true, isNew: true, id: "sol")
        ]
        try await localDataSource.saveCryptoCoins(replacement)
        let secondFetch = try await localDataSource.fetchCryptoCoins()

        XCTAssertEqual(secondFetch.count, 1)
        XCTAssertEqual(secondFetch.first?.id, "sol")
        XCTAssertEqual(secondFetch.first?.symbol, "SOL")
    }

    func testSaveEmptyArray_clearsCache() async throws {
        let coin = CryptoCoinEntity(name: "Bitcoin", symbol: "BTC", type: "coin", isActive: true, isNew: false, id: "btc")
        try await localDataSource.saveCryptoCoins([coin])
        try await localDataSource.saveCryptoCoins([])

        let fetched = try await localDataSource.fetchCryptoCoins()
        XCTAssertTrue(fetched.isEmpty)
    }

    // MARK: - Repository Tests
    func testRepositoryFetch_networkSuccessCachesOnce() async throws {
        let networkDS = MockNetworkDataSource()
        let localDS = MockLocalDataSource()
        let expected = [CryptoCoinEntity(name: "Bitcoin", symbol: "BTC", type: "coin", isActive: true, isNew: true, id: "btc")]
        networkDS.coinsToReturn = expected

        let repository = CryptoRepository(networkDataSource: networkDS, localDataSource: localDS)
        let result = try await repository.fetchCryptoCoins()

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(localDS.saveCallCount, 1)
        XCTAssertEqual(localDS.storedCoins.first?.id, "btc")
    }

    func testRepositoryFetch_networkFailureFallsBackToCache() async throws {
        let networkDS = MockNetworkDataSource()
        let localDS = MockLocalDataSource()
        networkDS.errorToThrow = NetworkError.noInternet
        localDS.storedCoins = [CryptoCoinEntity(name: "Ethereum", symbol: "ETH", type: "coin", isActive: true, isNew: false, id: "eth")]

        let repository = CryptoRepository(networkDataSource: networkDS, localDataSource: localDS)
        let result = try await repository.fetchCryptoCoins()

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.symbol, "ETH")
        XCTAssertEqual(localDS.saveCallCount, 0)
    }

    func testRepositoryFetch_networkFailureWithEmptyCacheThrowsNetworkError() async {
        let networkDS = MockNetworkDataSource()
        let localDS = MockLocalDataSource()
        networkDS.errorToThrow = NetworkError.noInternet
        localDS.storedCoins = []

        let repository = CryptoRepository(networkDataSource: networkDS, localDataSource: localDS)

        do {
            _ = try await repository.fetchCryptoCoins()
            XCTFail("Expected NetworkError.noInternet")
        } catch NetworkError.noInternet {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Network Data Source Tests
    func testNetworkDataSource_usesAPIServiceProtocol() async throws {
        let apiService = MockAPIService()
        apiService.coins = [CryptoCoinEntity(name: "Cardano", symbol: "ADA", type: "coin", isActive: true, isNew: false, id: "ada")]
        let dataSource = CryptoNetworkDataSourceImpl(apiService: apiService)

        let coins = try await dataSource.fetchCryptoCoins()
        XCTAssertEqual(coins.count, 1)
        XCTAssertEqual(coins.first?.symbol, "ADA")
    }
}
