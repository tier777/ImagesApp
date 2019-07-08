//
//  ImagesListViewModel.swift
//  ImagesTest
//
//  Created by Nikita Gorobets on 07/07/2019.
//  Copyright © 2019 ng. All rights reserved.
//

import RxSwift
import RxCocoa

protocol ImagesListViewModelProtocol: AnyObject {
    
    var searchResults: BehaviorRelay<[SearchResult]> { get }
    
    func fetchResults()
    func append(searchResult: SearchResult)
    func deleteResult(at row: Int)
}

class ImagesListViewModel {
    
    private let disposeBag = DisposeBag()
    
    private let coreDataManager: CoreDataManagerProtocol = CoreDataManager.shared
    
    let searchResults: BehaviorRelay<[SearchResult]> = BehaviorRelay(value: [])
    
    init() {
        
        fetchResults()
    }
}

extension ImagesListViewModel: ImagesListViewModelProtocol {
    
    func fetchResults() {
        
        searchResults.accept(coreDataManager.getSearchResults())
    }
    
    func append(searchResult: SearchResult) {
        
        let _ = coreDataManager.createStoredSearchResult(from: searchResult)
        coreDataManager.saveBackgroundContext()
        
        fetchResults()
    }
    
    func deleteResult(at row: Int) {
        
        let results = searchResults.value
        
        guard row < results.count else { return }
        
        coreDataManager.deleteStored(searchResult: results[row])
        coreDataManager.saveBackgroundContext()
        
        fetchResults()
    }
}
