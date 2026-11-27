//
//  CryptoListViewModel.swift
//  CryptoCoin
//
//  Created by Janesh Suthar.
//

import Foundation
import Common
import Domain

@MainActor
public final class CryptoListViewModel {

    // MARK: - Public state & callbacks
    public var allCoins: [CryptoCoinEntity] = []
    public var reloadTableView: (() -> Void)?
    public var showLoader: (() -> Void)?
    public var hideLoader: (() -> Void)?
    public var manageError: ((_ titleString: String, _ message: String) -> Void)?

    // MARK: - Private filter & search state
    private var searchQuery: String = ""
    private var activeFilter: Bool?
    private var inactiveFilter: Bool?
    private var onlyCoinsFilter: String?
    private var onlyTokensFilter: String?
    private var isNewFilter: Bool?

    // MARK: - Derived state
    public var filteredCoins: [CryptoCoinEntity] {
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return allCoins.filter { coin in
            // Status dimension: selecting both Active & Inactive includes both
            let matchesStatus: Bool
            switch (activeFilter, inactiveFilter) {
            case let (.some(active), .none):
                matchesStatus = coin.isActive == active
            case let (.none, .some(inactive)):
                matchesStatus = coin.isActive == !inactive
            case let (.some(active), .some(inactive)):
                matchesStatus = coin.isActive == active || coin.isActive == !inactive
            case (.none, .none):
                matchesStatus = true
            }

            // Type dimension: selecting both Only Coins & Only Tokens includes both
            let matchesType: Bool
            switch (onlyCoinsFilter, onlyTokensFilter) {
            case let (.some(coinType), .none):
                matchesType = coin.type == coinType
            case let (.none, .some(tokenType)):
                matchesType = coin.type == tokenType
            case let (.some(coinType), .some(tokenType)):
                matchesType = coin.type == coinType || coin.type == tokenType
            case (.none, .none):
                matchesType = true
            }

            // Newness dimension
            let matchesNew = isNewFilter.map { coin.isNew == $0 } ?? true

            // Search dimension
            let matchesSearch = trimmedQuery.isEmpty ||
                coin.name.lowercased().contains(trimmedQuery) ||
                coin.symbol.lowercased().contains(trimmedQuery)

            return matchesStatus && matchesType && matchesNew && matchesSearch
        }
    }

    public var isFilteredCoinsEmpty: Bool {
        filteredCoins.isEmpty
    }

    // MARK: - Dependencies
    private let getCryptoCoinsUseCase: any FetchCryptoCoinsUseCaseProtocol

    // MARK: - Init (synchronous, side-effect free)
    public init(getCryptoCoinsUseCase: any FetchCryptoCoinsUseCaseProtocol) {
        self.getCryptoCoinsUseCase = getCryptoCoinsUseCase
    }

    // MARK: - Fetch
    public func fetchCoins() async {
        showLoader?()
        defer {
            reloadTableView?()
            hideLoader?()
        }
        do {
            let coins = try await getCryptoCoinsUseCase.execute()
            self.allCoins = coins
        } catch {
            self.manageError?("Error", error.localizedDescription)
        }
    }

    // MARK: - Filter
    public func filterCoins(
        isActive: Bool?,
        isInactive: Bool?,
        onlyCoins: String?,
        isNew: Bool?,
        onlyTokens: String?
    ) {
        activeFilter = isActive
        inactiveFilter = isInactive
        onlyCoinsFilter = onlyCoins
        onlyTokensFilter = onlyTokens
        isNewFilter = isNew
        reloadTableView?()
    }

    // MARK: - Search
    public func searchCoins(query: String) {
        searchQuery = query
        reloadTableView?()
    }
}
