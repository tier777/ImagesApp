//
//  ImagesAPI.swift
//  ImagesTest
//
//  Created by Nikita Gorobets on 07/07/2019.
//  Copyright © 2019 ng. All rights reserved.
//

import Foundation

protocol APIProtocol {
    
    static var base: String { get }
}

protocol APIItem {
    
    var path: String { get }
    var url: URL { get }
}

enum ImagesAPI: APIProtocol {
    
    static let base = "https://yandex.ru/"
    
    case images(q: String)
}

extension ImagesAPI: APIItem {
    
    var path: String {
        
        switch self {
        case .images(let q):
            
            return "images/search?text=\(q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? q)"
        }
    }
    
    var url: URL {
        
        guard let url = URL(string: ImagesAPI.base + path) else {
            
            return URL(string: ImagesAPI.base)!
        }
        
        return url
    }
}
