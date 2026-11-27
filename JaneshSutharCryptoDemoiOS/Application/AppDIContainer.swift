//
//  AppDIContainer.swift
//  CryptoCoin
//
//  Created by Janesh Suthar.
//

import UIKit
import Infrastructure
import Data
import Domain
import Presentation

@MainActor
final class AppDIContainer {
    static func makeCoinListViewController() throws -> UIViewController {
        let networkManager = NetworkManager()
        let apiService = NetworkServiceManager(networkManager: networkManager)
        let networkDataSource = CryptoNetworkDataSourceImpl(apiService: apiService)
        let coreDataHelper = try CoreDataHelper()
        let localDataSource = CryptoLocalDataSourceImpl(coreDataHelper: coreDataHelper)
        let repository = CryptoRepository(networkDataSource: networkDataSource, localDataSource: localDataSource)
        let useCase = FetchCryptoCoinsUseCase(repository: repository)
        let viewModel = CryptoListViewModel(getCryptoCoinsUseCase: useCase)
        let viewController = CryptoListViewController(viewModel: viewModel)
        return UINavigationController(rootViewController: viewController)
    }
}
