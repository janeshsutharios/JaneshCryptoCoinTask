//
//  File.swift
//  Data
//
//  Created by Janesh Suthar on 19/01/25.
//

import Foundation
import Domain
import CoreData
import CoreData

public class CoreDataHelper {
    private let persistentContainer: NSPersistentContainer

    public init() {
        guard let modelURL = Bundle.module.url(forResource: "CryptoCoin", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to load Core Data model")
        }
        persistentContainer = NSPersistentContainer(name: "CryptoCoin", managedObjectModel: model)
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
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
        var saveError: Error? // Capture error outside the closure
        context.performAndWait {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    saveError = error // Assign error to saveError
                }
            }
        }
        if let error = saveError {
            throw error // Throw the error outside the closure
        }
    }
}
