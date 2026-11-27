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

        let deletedIDs: [NSManagedObjectID] = try await context.perform {
            do {
                let fetchRequest: NSFetchRequest<any NSFetchRequestResult> = CryptoCoinCoreData.fetchRequest()
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                deleteRequest.resultType = .resultTypeObjectIDs
                let deleteResult = try context.execute(deleteRequest) as? NSBatchDeleteResult
                let ids = deleteResult?.result as? [NSManagedObjectID] ?? []

                for coin in coins {
                    _ = coin.toCoreData(context: context)
                }

                return ids
            } catch {
                throw LocalStorageError.failedToSave
            }
        }

        // Persist the background context first before updating mainContext
        try await coreDataHelper.save(context: context)

        // Merge batch-deleted object IDs safely on mainContext's queue
        if !deletedIDs.isEmpty {
            let mainContext = await coreDataHelper.mainContext
            await mainContext.perform {
                let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: deletedIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [mainContext])
            }
        }
    }
}
