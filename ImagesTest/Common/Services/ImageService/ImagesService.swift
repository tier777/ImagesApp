//
//  ImagesService.swift
//  ImagesTest
//
//  Created by Nikita Gorobets on 07/07/2019.
//  Copyright © 2019 ng. All rights reserved.
//

import RxSwift
import RxCocoa
import Kanna

protocol ImagesServiceProtocol {
    
    static var shared: ImagesServiceProtocol { get }
    
    func searchImages(q: String) -> Observable<[SearchResult]>
    func getImage(for searchResult: SearchResult) -> Observable<UIImage?>
}

class ImagesService {
    
    private init() {}
    
    static let shared: ImagesServiceProtocol = ImagesService()
    
    private let coreDataManager = CoreDataManager.shared
    private let networkManager = NetworkManager()
    private let cache = NSCache<NSString, UIImage>()
    
    private func getImagesFrom(htmlString: String, request: String) -> [SearchResult] {
        
        guard let document = try? HTML(html: htmlString, encoding: .utf8) else {
            
            return []
        }
        
        let images = document.xpath("//img[@class='serp-item__thumb justifier__thumb']").compactMap {
            (node) -> SearchResult? in
            
            guard let srcUrl = node["src"] else { return nil }
            
            let imageUrl = srcUrl.replacingOccurrences(of: "//", with: "https://")
            let searchResult = coreDataManager.createTempSearchResult(request: request, imageUrl: imageUrl, imageData: cache.object(forKey: NSString(string: imageUrl))?.pngData())
            
            return searchResult
        }
        
        return images
    }
}

extension ImagesService: ImagesServiceProtocol {
    
    func searchImages(q: String) -> Observable<[SearchResult]> {
        
        let url = ImagesAPI.images(q: q).url
        
        let observable: Observable<[SearchResult]> = networkManager.get(from: url).map {
            [weak self] htmlString -> [SearchResult] in
            
            return self?.getImagesFrom(htmlString: htmlString, request: url.absoluteString) ?? []
        }
        
        return observable
    }
    
    func getImage(for searchResult: SearchResult) -> Observable<UIImage?> {
        
        guard let url = URL(string: searchResult.imageUrl ?? "") else {
            
            return Observable.just(nil)
        }
        
        let imageKey = NSString(string: searchResult.imageUrl ?? "")
        
        if let cachedImage = cache.object(forKey: imageKey) {
            
            return Observable.just(cachedImage)
        }
        
        let observable: Observable<Data> = networkManager.get(from: url)
        
        return observable.map {
            [weak self] data -> UIImage? in
            
            if let image = UIImage(data: data) {
                
                self?.cache.setObject(image, forKey: imageKey)
                
                return image
            }
            
            return nil
        }
    }
}
