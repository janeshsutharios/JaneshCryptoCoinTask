//
//  CryptoListViewModelTests.swift
//  CryptoCoinTests
//
//  Created by Janesh Suthar
//

import XCTest
import Domain
@testable import Presentation

@MainActor
final class CryptoListViewModelTests: XCTestCase {

    private var viewModel: CryptoListViewModel!
    private var mockUseCase: MockGetCryptoCoinsUseCase!

    private let sampleCoins: [CryptoCoinEntity] = [
        CryptoCoinEntity(name: "Bitcoin", symbol: "BTC", type: "coin", isActive: true, isNew: false, id: "btc"),
        CryptoCoinEntity(name: "Ethereum", symbol: "ETH", type: "coin", isActive: false, isNew: false, id: "eth"),
        CryptoCoinEntity(name: "Tether", symbol: "USDT", type: "token", isActive: true, isNew: true, id: "usdt"),
        CryptoCoinEntity(name: "Beta Token", symbol: "BETA", type: "token", isActive: false, isNew: true, id: "beta")
    ]

    override func setUp() async throws {
        try await super.setUp()
        mockUseCase = MockGetCryptoCoinsUseCase()
        viewModel = CryptoListViewModel(getCryptoCoinsUseCase: mockUseCase)
    }

    override func tearDown() async throws {
        viewModel = nil
        mockUseCase = nil
        try await super.tearDown()
    }

    // MARK: - Init & Fetch Tests
    func testInit_doesNotTriggerFetch() {
        XCTAssertEqual(mockUseCase.executeCallCount, 0)
        XCTAssertTrue(viewModel.allCoins.isEmpty)
        XCTAssertTrue(viewModel.filteredCoins.isEmpty)
    }

    func testFetchCoinsSuccess_populatesCoinsAndCallsCallbacksInOrder() async {
        mockUseCase.mockedCoins = sampleCoins
        var events: [String] = []
        viewModel.showLoader = { events.append("showLoader") }
        viewModel.reloadTableView = { events.append("reload") }
        viewModel.hideLoader = { events.append("hideLoader") }

        await viewModel.fetchCoins()

        XCTAssertEqual(mockUseCase.executeCallCount, 1)
        XCTAssertEqual(viewModel.allCoins.count, 4)
        XCTAssertEqual(viewModel.filteredCoins.count, 4)
        XCTAssertEqual(events, ["showLoader", "reload", "hideLoader"])
    }

    func testFetchCoinsFailure_triggersManageErrorAndStillHidesLoader() async {
        mockUseCase.errorToThrow = NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Offline"])
        var events: [String] = []
        var capturedMessage: String?
        viewModel.showLoader = { events.append("showLoader") }
        viewModel.manageError = { _, message in
            events.append("error")
            capturedMessage = message
        }
        viewModel.reloadTableView = { events.append("reload") }
        viewModel.hideLoader = { events.append("hideLoader") }

        await viewModel.fetchCoins()

        XCTAssertEqual(capturedMessage, "Offline")
        XCTAssertTrue(viewModel.allCoins.isEmpty)
        XCTAssertEqual(events, ["showLoader", "error", "reload", "hideLoader"])
    }

    // MARK: - Filter Tests
    func testFilterActiveCoins() {
        viewModel.allCoins = sampleCoins
        viewModel.filterCoins(isActive: true, isInactive: nil, onlyCoins: nil, isNew: nil, onlyTokens: nil)
        XCTAssertEqual(viewModel.filteredCoins.map(\.symbol), ["BTC", "USDT"])
    }

    func testFilterInactiveCoins() {
        viewModel.allCoins = sampleCoins
        viewModel.filterCoins(isActive: nil, isInactive: true, onlyCoins: nil, isNew: nil, onlyTokens: nil)
        XCTAssertEqual(viewModel.filteredCoins.map(\.symbol), ["ETH", "BETA"])
    }

    func testFilterOnlyCoinsAndOnlyTokensSeparately() {
        viewModel.allCoins = sampleCoins

        viewModel.filterCoins(isActive: nil, isInactive: nil, onlyCoins: "coin", isNew: nil, onlyTokens: nil)
        XCTAssertEqual(viewModel.filteredCoins.map(\.symbol), ["BTC", "ETH"])

        viewModel.filterCoins(isActive: nil, isInactive: nil, onlyCoins: nil, isNew: nil, onlyTokens: "token")
        XCTAssertEqual(viewModel.filteredCoins.map(\.symbol), ["USDT", "BETA"])
    }

    func testFilterNewCoins() {
        viewModel.allCoins = sampleCoins
        viewModel.filterCoins(isActive: nil, isInactive: nil, onlyCoins: nil, isNew: true, onlyTokens: nil)
        XCTAssertEqual(viewModel.filteredCoins.map(\.symbol), ["USDT", "BETA"])
    }

    func testFilterOppositePairs_includesAllInDimension() {
        viewModel.allCoins = sampleCoins

        // Both Active + Inactive selected -> all statuses included
        viewModel.filterCoins(isActive: true, isInactive: true, onlyCoins: nil, isNew: nil, onlyTokens: nil)
        XCTAssertEqual(viewModel.filteredCoins.count, 4)

        // Both Only Coins + Only Tokens selected -> all types included
        viewModel.filterCoins(isActive: nil, isInactive: nil, onlyCoins: "coin", isNew: nil, onlyTokens: "token")
        XCTAssertEqual(viewModel.filteredCoins.count, 4)
    }

    // MARK: - Search Tests
    func testSearchByNameAndSymbolCaseInsensitive() {
        viewModel.allCoins = sampleCoins

        viewModel.searchCoins(query: "ethereum")
        XCTAssertEqual(viewModel.filteredCoins.map(\.symbol), ["ETH"])

        viewModel.searchCoins(query: "usdt")
        XCTAssertEqual(viewModel.filteredCoins.map(\.symbol), ["USDT"])

        viewModel.searchCoins(query: "")
        XCTAssertEqual(viewModel.filteredCoins.count, 4)
    }

    func testSearchNoMatch_setsIsFilteredCoinsEmpty() {
        viewModel.allCoins = sampleCoins
        viewModel.searchCoins(query: "DOGE")
        XCTAssertTrue(viewModel.isFilteredCoinsEmpty)
    }

    // MARK: - Combined Search + Filter Tests
    func testSearchAndFilter_combinedWithoutOverwritingEachOther() {
        viewModel.allCoins = sampleCoins

        // Filter active first, then search "t" (matches Bitcoin & Tether; Tether is active, Beta is inactive)
        viewModel.filterCoins(isActive: true, isInactive: nil, onlyCoins: nil, isNew: nil, onlyTokens: nil)
        viewModel.searchCoins(query: "t")
        XCTAssertEqual(viewModel.filteredCoins.map(\.symbol), ["BTC", "USDT"])

        // Clear search -> active filter remains intact
        viewModel.searchCoins(query: "")
        XCTAssertEqual(viewModel.filteredCoins.map(\.symbol), ["BTC", "USDT"])

        // Apply search first, then narrow with filter -> search remains intact
        viewModel.searchCoins(query: "t")
        viewModel.filterCoins(isActive: nil, isInactive: nil, onlyCoins: nil, isNew: true, onlyTokens: "token")
        XCTAssertEqual(viewModel.filteredCoins.map(\.symbol), ["USDT", "BETA"])
    }
}
