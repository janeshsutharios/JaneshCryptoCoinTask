//
//  CoinListViewModel.swift
//  CryptoCoin
//
//  Created by Janesh Suthar.
//

import Foundation
import Common
@preconcurrency import Domain

@MainActor
public final class CryptoListViewModel {
    
    public var allCoins: [CryptoCoinEntity] = []
    public var filteredCoins: [CryptoCoinEntity] = []
    public var reloadTableView: (() -> Void)?
    var showLoader: (() -> Void)?
    var hideLoader: (() -> Void)?
    public var manageError: ((_ titleString: String, _ message: String) -> Void)?
    
    var isFilteredCoinsEmpty: Bool {
        return filteredCoins.isEmpty
    }
    
    private let getCryptoCoinsUseCase: FetchCryptoCoinsUseCase
    
    public init(getCryptoCoinsUseCase: FetchCryptoCoinsUseCase) async {
        self.getCryptoCoinsUseCase = getCryptoCoinsUseCase
        await fetchCoins()
    }
   
    public func fetchCoins() async {
        showLoader?()
        do {
            // Decide whether to fetch from network or local storage based on connectivity
            let coins = try await fetchCoinsBasedOnNetworkStatus()
            // Update UI with the fetched coins
            self.allCoins = coins
            self.filteredCoins = coins
        } catch {
            // Handle any error that occurs during fetching
            self.manageError?("Error", error.localizedDescription)
        }
        self.reloadTableView?()
        // Hide the loader after the operation is complete (whether it succeeded or failed)
        self.hideLoader?()
    }
    
    private nonisolated func fetchCoinsBasedOnNetworkStatus() async throws -> [CryptoCoinEntity] {
        if Reachability.isConnectedToNetwork() {
            // Fetch from the network if connected
            return try await getCryptoCoinsUseCase.execute(fromNetwork: true)
        } else {
            // Fetch from local storage if no internet connection
            return try await getCryptoCoinsUseCase.execute(fromNetwork: false)
        }
    }
    
    public func filterCoins(isActive: Bool?, isInactive: Bool?, onlyCoins: String?, isNew: Bool?, onlyTokens: String?) {
        filteredCoins = allCoins.filter { coin in
            var matches = true
            if let isActive = isActive {
                matches = matches && coin.isActive == isActive
            }
            if let isInactive = isInactive {
                matches = matches && coin.isActive == !isInactive
            }
            if let onlyCoins = onlyCoins {
                matches = matches && coin.type == onlyCoins
            }
            if let onlyTokens = onlyTokens {
                matches = matches && coin.type == onlyTokens
            }
            if let isNew = isNew {
                matches = matches && coin.isNew == isNew
            }
            return matches
        }
        reloadTableView?()
    }
    
    public func searchCoins(query: String) {
        if query.isEmpty {
            // If the search text is empty, show the original data (allCoins)
            filteredCoins = allCoins
        } else {
            // Filter the coins based on the search query
            filteredCoins = allCoins.filter {
                $0.name.lowercased().contains(query.lowercased()) ||
                $0.symbol.lowercased().contains(query.lowercased())
            }
        }
        reloadTableView?()  // Trigger table reload
    }
}

