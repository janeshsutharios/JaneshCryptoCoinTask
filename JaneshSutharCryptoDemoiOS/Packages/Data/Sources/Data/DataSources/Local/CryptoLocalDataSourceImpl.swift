
//
//  CryptoLocalDataSource.swift
//  CryptoCoin
//
//  Created by Janesh
//

import Foundation
import CoreData
import Domain

public final class CryptoLocalDataSourceImpl: CryptoLocalDataSource {
    private let coreDataHelper: CoreDataHelper

    /// Pass an instance of `CoreDataHelper` to remove dependency on a singleton
    public init(coreDataHelper: CoreDataHelper) {
        self.coreDataHelper = coreDataHelper
    }
    
    /// Fetches crypto coins from the local database
    public func fetchCryptoCoins() async throws -> [CryptoCoinEntity] {
        let context = coreDataHelper.mainContext
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
        let context = coreDataHelper.newBackgroundContext()
        return try await withCheckedThrowingContinuation { continuation in
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
                    
                    // Save context
                    try self.coreDataHelper.save(context: context)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: LocalStorageError.failedToSave)
                }
            }
        }
    }
}
