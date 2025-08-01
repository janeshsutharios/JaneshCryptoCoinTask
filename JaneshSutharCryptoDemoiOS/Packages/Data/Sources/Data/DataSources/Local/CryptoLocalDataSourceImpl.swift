
//
//  CryptoLocalDataSource.swift
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
        return try await withCheckedThrowingContinuation { continuation in
            context.perform {
                let fetchRequest: NSFetchRequest<CryptoCoinCoreData> = CryptoCoinCoreData.fetchRequest()
                do {
                    let coreDataCoins = try context.fetch(fetchRequest)
                    let domainModels = coreDataCoins.map { $0.toDomain() }
                    continuation.resume(returning: domainModels)
                } catch {
                    continuation.resume(throwing: LocalStorageError.objectNotFound)
                }
            }
        }
    }

    
    /// Saves crypto coins to the local database
    public func saveCryptoCoins(_ coins: [CryptoCoinEntity]) async throws {
        let context = await coreDataHelper.newBackgroundContext()
        
        try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    // Delete existing entries
                    let fetchRequest: NSFetchRequest<any NSFetchRequestResult> = CryptoCoinCoreData.fetchRequest()
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    try context.execute(deleteRequest)

                    // Add new coins
                    for coin in coins {
                        _ = coin.toCoreData(context: context)
                    }
                    
                    continuation.resume() // resume on success
                } catch {
                    continuation.resume(throwing: LocalStorageError.failedToSave)
                }
            }
        }
        
        // Now save the context outside of context.perform
        // This happens on the right actor executor with await
        try await coreDataHelper.save(context: context)
    }
}
