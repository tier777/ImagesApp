//
//  CoreDataManager.swift
//  ImagesTest
//
//  Created by Nikita Gorobets on 06/07/2019.
//  Copyright © 2019 ng. All rights reserved.
//

import CoreData

protocol CoreDataManagerProtocol {
    
    static var shared: CoreDataManagerProtocol { get }
    
    func saveMainContext()
    func saveBackgroundContext()
    
    func createStoredSearchResult(from searchResult: SearchResult) -> SearchResult
    func createTempSearchResult(request: String, imageUrl: String, imageData: Data?) -> SearchResult
    func deleteStored(searchResult: SearchResult)
    func getSearchResults() -> [SearchResult]
}

class CoreDataManager {
    
    private init() {}
    
    static let shared: CoreDataManagerProtocol = CoreDataManager()
    
    private var mainContext: NSManagedObjectContext {
        
        return persistentContainer.viewContext
    }
    
    private lazy var backgroundContext: NSManagedObjectContext = {
        
        return persistentContainer.newBackgroundContext()
    }()
    
    private lazy var tempContext: NSManagedObjectContext = {
        
        return persistentContainer.newBackgroundContext()
    }()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "ImagesTest")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            
            if let error = error as NSError? {
                
                print("PersistentContainer error: \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private func save(context: NSManagedObjectContext) {
        
        if context.hasChanges {
            
            do {
                
                try context.save()
                
            } catch {
                
                let nserror = error as NSError
                print("Saving context \(context.name ?? "") error: \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension CoreDataManager: CoreDataManagerProtocol {
    
    func saveMainContext() {
        
        save(context: mainContext)
    }
    
    func saveBackgroundContext() {
        
        save(context: backgroundContext)
    }
    
    func createStoredSearchResult(from searchResult: SearchResult) -> SearchResult {
        
        let entity = SearchResult(context: backgroundContext)
        entity.createdAt = Date()
        entity.request = searchResult.request
        entity.imageUrl = searchResult.imageUrl
        entity.imageData = searchResult.imageData
        
        return entity
    }
    
    func createTempSearchResult(request: String, imageUrl: String, imageData: Data?) -> SearchResult {
        
        let entity = SearchResult(context: tempContext)
        entity.createdAt = Date()
        entity.request = request
        entity.imageUrl = imageUrl
        entity.imageData = imageData
        
        return entity
    }
    
    func deleteStored(searchResult: SearchResult) {
        
        backgroundContext.delete(searchResult)
    }
    
    func getSearchResults() -> [SearchResult] {
        
        let fetchRequest = NSFetchRequest<SearchResult>(entityName: "SearchResult")
        
        if let results = try? backgroundContext.fetch(fetchRequest) {
            
            return results
        }
        
        return []
    }
}
