//
//  ImagesService.swift
//  ImagesTest
//
//  Created by Nikita Gorobets on 07/07/2019.
//  Copyright © 2019 ng. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Kanna

struct ServiceImage {
    
    let request: String
    let imageUrl: String
}

protocol ImagesServiceProtocol {
    
    func searchImages(q: String) -> Observable<[ServiceImage]>
}

class ImagesService {
    
    private let networkManager = NetworkManager()
    
    private func getImagesFrom(htmlString: String, request: String) -> [ServiceImage] {
        
        guard let document = try? HTML(html: htmlString, encoding: .utf8) else {
            
            return []
        }
        
        let images = document.xpath("//img[@class='serp-item__thumb justifier__thumb']").compactMap {
            (node) -> ServiceImage? in
            
            guard let srcUrl = node["src"] else { return nil }
            
            let image = ServiceImage(request: request, imageUrl: srcUrl.replacingOccurrences(of: "//", with: "https://"))
            
            return image
        }
        
        return images
    }
}

extension ImagesService: ImagesServiceProtocol {
    
    func searchImages(q: String) -> Observable<[ServiceImage]> {
        
        let url = URL(string: "https://yandex.ru/images/search?text=\(q)")!
        
        let observable: Observable<[ServiceImage]> = networkManager.get(from: url).map {
            (htmlString) -> [ServiceImage] in
            
            return self.getImagesFrom(htmlString: htmlString, request: url.absoluteString)
        }
        
        return observable
    }
}
