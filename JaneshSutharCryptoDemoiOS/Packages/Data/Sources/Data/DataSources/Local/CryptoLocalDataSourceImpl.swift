//
//  CryptoLocalDataSourceImpl.swift
//  CryptoCoin
//
//  Created by Janesh
//

import Foundation
@preconcurrency import CoreData
import Domain

public actor CryptoLocalDataSourceImpl: CryptoLocalDataSource {
    private let coreDataHelper: CoreDataHelper

    /// Pass an instance of `CoreDataHelper` to remove dependency on a singleton
    public init(coreDataHelper: CoreDataHelper) {
        self.coreDataHelper = coreDataHelper
    }

    /// Fetches crypto coins from the local database
    public func fetchCryptoCoins() async throws -> [CryptoCoinEntity] {
        let context = await coreDataHelper.mainContext
        return try await context.perform {
            let fetchRequest: NSFetchRequest<CryptoCoinCoreData> = CryptoCoinCoreData.fetchRequest()
            do {
                let coreDataCoins = try context.fetch(fetchRequest)
                return coreDataCoins.map { $0.toDomain() }
            } catch {
                throw LocalStorageError.objectNotFound
            }
        }
    }

    /// Saves crypto coins to the local database
    public func saveCryptoCoins(_ coins: [CryptoCoinEntity]) async throws {
        let context = await coreDataHelper.newBackgroundContext()

        try await context.perform {
            do {
                let fetchRequest: NSFetchRequest<CryptoCoinCoreData> = CryptoCoinCoreData.fetchRequest()
                let existingCoins = try context.fetch(fetchRequest)
                for existingCoin in existingCoins {
                    context.delete(existingCoin)
                }

                for coin in coins {
                    _ = coin.toCoreData(context: context)
                }
            } catch {
                context.rollback()
                throw LocalStorageError.failedToSave
            }
        }

        // Persist deletions and insertions atomically in one context save;
        // CoreDataHelper.mainContext merges changes automatically.
        do {
            try await coreDataHelper.save(context: context)
        } catch {
            await context.perform {
                context.rollback()
            }
            throw LocalStorageError.failedToSave
        }
    }
}
