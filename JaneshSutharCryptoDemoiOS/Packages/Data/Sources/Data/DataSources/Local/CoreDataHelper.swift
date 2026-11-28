//
//  CoreDataHelper.swift
//  Data
//
//  Created by Janesh Suthar on 19/01/25.
//

import Foundation
import Domain
@preconcurrency import CoreData

public enum CoreDataError: Error, Sendable {
    case modelNotFound
    case storeLoadFailed(any Error)
}

public actor CoreDataHelper {
    private let persistentContainer: NSPersistentContainer

    public init(inMemory: Bool = false) throws {
        guard let modelURL = Bundle.module.url(forResource: "CryptoCoin", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            throw CoreDataError.modelNotFound
        }
        let container = NSPersistentContainer(name: "CryptoCoin", managedObjectModel: model)
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions = [description]
        }
        var storeError: (any Error)?
        container.loadPersistentStores { _, error in
            storeError = error
        }
        if let error = storeError {
            throw CoreDataError.storeLoadFailed(error)
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        self.persistentContainer = container
    }

    /// Main context for UI updates
    public var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    /// Creates a private background context
    public func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }

    /// Saves a specific context
    public func save(context: NSManagedObjectContext) throws {
        try context.performAndWait {
            if context.hasChanges {
                try context.save()
            }
        }
    }
}
