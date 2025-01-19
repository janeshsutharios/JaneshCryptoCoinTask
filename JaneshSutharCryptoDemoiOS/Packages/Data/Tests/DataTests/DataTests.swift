// XCTest Documentation
// https://developer.apple.com/documentation/xctest

// Defining Test Cases and Test Methods
// https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods

import XCTest
import CoreData
@testable import Data // Replace with your module name

final class CoreDataHelperTests: XCTestCase {
    
    var coreDataHelper: CoreDataHelper!
    var persistentContainer: NSPersistentContainer!
    
    override func setUp() {
        super.setUp()
        
        // Create an in-memory NSPersistentContainer for testing
        let modelURL = Bundle.module.url(forResource: "CryptoCoin", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        persistentContainer = NSPersistentContainer(name: "CryptoCoin", managedObjectModel: model)
        
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType // In-memory store for testing
        persistentContainer.persistentStoreDescriptions = [description]
        
        persistentContainer.loadPersistentStores { description, error in
            XCTAssertNil(error, "Failed to load in-memory store: \(error?.localizedDescription ?? "")")
        }
        
        coreDataHelper = CoreDataHelper() // Initialize CoreDataHelper
    }
    
    override func tearDown() {
        persistentContainer = nil
        coreDataHelper = nil
        super.tearDown()
    }
    
    func testSaveContextSuccessfully() throws {
        let context = persistentContainer.viewContext
        
        // Create a mock object in the context if there is no data
        let fetchRequest: NSFetchRequest<CryptoCoinCoreData> = CryptoCoinCoreData.fetchRequest()
        let existingCoins = try context.fetch(fetchRequest)
        
        if existingCoins.isEmpty {
            // If no data, add a new object
            let cryptoCoin = CryptoCoinCoreData(context: context)
            cryptoCoin.id = UUID().uuidString
            cryptoCoin.name = "Bitcoin"
            cryptoCoin.symbol = "BTC"
            cryptoCoin.isActive = true
            cryptoCoin.isNew = false
            cryptoCoin.type = "Cryptocurrency"
            
            XCTAssertTrue(context.hasChanges)
            
            // Save the context
            XCTAssertNoThrow(try coreDataHelper.save(context: context), "Context save should not throw an error")
        }
        
        // Fetch data again to check if the object is saved or not
        let results = try context.fetch(fetchRequest)
        
        // Assert that there's at least one item in the database
        XCTAssertGreaterThanOrEqual(results.count, 1, "There should be at least one coin in Core Data")
        
        // Optionally, validate the fetched data
        if let firstCoin = results.first {
            XCTAssertEqual(firstCoin.name, "Bitcoin")
        }
    }
    
    func testSaveContextThrowsError() throws {
        let context = persistentContainer.viewContext
        
        // Add an invalid object (e.g., missing a required field)
        let cryptoCoin = CryptoCoinCoreData(context: context)
        cryptoCoin.id = nil // Required field is nil
        
        // Ensure the context has changes before saving
        XCTAssertTrue(context.hasChanges)
        
        // Attempt to save and expect an error
        XCTAssertThrowsError(try coreDataHelper.save(context: context), "Context save should throw an error due to missing required fields") { error in
            XCTAssertNotNil(error, "Error should not be nil")
        }
    }
}
