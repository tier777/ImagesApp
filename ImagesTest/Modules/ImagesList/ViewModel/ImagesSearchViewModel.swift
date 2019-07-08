//
//  ImagesSearchViewModel.swift
//  ImagesTest
//
//  Created by Nikita Gorobets on 07/07/2019.
//  Copyright © 2019 ng. All rights reserved.
//

import RxSwift
import RxCocoa

protocol ImagesSearchViewModelProtocol: AnyObject {
    
    var images: BehaviorRelay<[SearchResult]> { get }
    var currentImage: BehaviorRelay<UIImage?> { get }
    
    func search(q: String)
    func shuffle()
}

class ImagesSearchViewModel {
    
    private let disposeBag = DisposeBag()
    
    private let coreDataManager = CoreDataManager.shared
    private let imagesService = ImagesService.shared
    
    let images: BehaviorRelay<[SearchResult]> = BehaviorRelay(value: [])
    private let currentResult: BehaviorRelay<SearchResult?> = BehaviorRelay(value: nil)
    let currentImage: BehaviorRelay<UIImage?> = BehaviorRelay(value: nil)
    
    init() {
        
        images.bind(onNext: {
            [weak self] images in
            
            self?.currentResult.accept(images.randomElement())
            
        }).disposed(by: disposeBag)
        
        currentResult.bind(onNext: {
            [weak self] searchResult in
            
            guard let self = self, let searchResult = searchResult else { return }
            
            self.imagesService.getImage(for: searchResult).subscribe(onNext: {
                [weak self] image in
                
                self?.currentResult.value?.imageData = image?.pngData()
                
                self?.currentImage.accept(image)

            }).disposed(by: self.disposeBag)
            
        }).disposed(by: disposeBag)
    }
}

extension ImagesSearchViewModel: ImagesSearchViewModelProtocol {
    
    func search(q: String) {
        
        guard !q.isEmpty else { return }
        
        let imagesSearch: Observable<[SearchResult]> = imagesService.searchImages(q: q)
        imagesSearch.observeOn(SerialDispatchQueueScheduler(qos: .utility))
            .subscribe(onNext: {
                [weak self] images in
                
                self?.images.accept(images)
                
                }, onError: { (error) in
                    
                    print(error.localizedDescription)
                    
            }).disposed(by: disposeBag)
    }
    
    func shuffle() {
        
        guard let currentResult = currentResult.value else { return }
        
        var images = self.images.value
        images.removeAll(where: { $0.imageUrl == currentResult.imageUrl })
        
        self.currentResult.accept(images.randomElement())
    }
}
