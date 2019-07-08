//
//  ImagesListCellViewModel.swift
//  ImagesTest
//
//  Created by Nikita Gorobets on 08/07/2019.
//  Copyright © 2019 ng. All rights reserved.
//

import RxSwift
import RxCocoa

protocol ImagesListCellViewModelProtocol {
    
    var url: BehaviorRelay<String?> { get }
    var imageData: BehaviorRelay<Data?> { get }
}

class ImagesListCellViewModel: ImagesListCellViewModelProtocol {
    
    private let searchResult: SearchResult
    
    let url: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let imageData: BehaviorRelay<Data?> = BehaviorRelay(value: nil)
    
    init(searchResult: SearchResult) {
        
        self.searchResult = searchResult
        
        url.accept(searchResult.request)
        imageData.accept(searchResult.imageData)
    }
}
