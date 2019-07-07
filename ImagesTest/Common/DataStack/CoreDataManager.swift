//
//  CoreDataManager.swift
//  ImagesTest
//
//  Created by Nikita Gorobets on 06/07/2019.
//  Copyright © 2019 ng. All rights reserved.
//

import CoreData
import class UIKit.UIImage

protocol CoreDataManagerProtocol {
    
    static var shared: CoreDataManagerProtocol { get }
    
    func saveMainContext()
    func saveBackgroundContext()
    
    func createSearchResult(request: String, image: UIImage) -> SearchResult
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
    
    private lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "ImagesTest")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            
            print("store done!")
            
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private func save(context: NSManagedObjectContext) {
        
        if context.hasChanges {
            do {
                
                try context.save()
                
                print("\(context.name ?? "") context saved.")
                
            } catch {
                
                let nserror = error as NSError
                fatalError("Saving context \(context.name ?? "") error: \(nserror), \(nserror.userInfo)")
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
    
    func createSearchResult(request: String, image: UIImage) -> SearchResult {
        
        let entity = SearchResult(context: backgroundContext)
        entity.createdAt = Date()
        entity.request = request
        entity.image = image.pngData()
        
        return entity
    }
    
    func getSearchResults() -> [SearchResult] {
        
        let fetchRequest = NSFetchRequest<SearchResult>(entityName: "SearchResult")
        
        if let results = try? backgroundContext.fetch(fetchRequest) {
            
            print("res count: \(results.count)")
            
            return results
        }
        
        return []
    }
}
