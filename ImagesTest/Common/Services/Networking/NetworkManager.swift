//
//  NetworkManager.swift
//  ImagesTest
//
//  Created by Nikita Gorobets on 07/07/2019.
//  Copyright © 2019 ng. All rights reserved.
//

import Foundation
import RxSwift

protocol NetworkManagerProtocol: AnyObject {
    
    func get<T: NetworkResponse>(from url: URL) -> Observable<T>
}

class NetworkManager {
    
    private func check(response: URLResponse?, error: Error?) -> Error? {
        
        if let error = error {
            
            return error
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            
            return NetworkResponseError.noContent
        }
        
        return httpResponse.statusCode == 404 ? NetworkResponseError.notFound : nil
    }
    
    private func parse<T: NetworkResponse>(responseData: Data?) -> Result<T, Error> {
        
        guard let data = responseData else {
            
            return .failure(NetworkResponseError.noContent)
        }
        
        switch T.self {
        case is String.Type:
            
            if let string = String(data: data, encoding: .utf8) as? T {
                
                return .success(string)
            }
            
        case is Data.Type:
            
            if let data = data as? T {
                
                return .success(data)
            }
            
        default: break
        }
        
        return .failure(NetworkResponseError.responseParsingError)
    }
}

extension NetworkManager: NetworkManagerProtocol {
    
    func get<T: NetworkResponse>(from url: URL) -> Observable<T> {
        
        return Observable<T>.create({ (observer) -> Disposable in
            
            let dataTask = URLSession.shared.dataTask(with: url) {
                [weak self] data, response, error in
                
                guard let self = self else { return }
                
                if let error = self.check(response: response, error: error) {
                    
                    observer.onError(error)
                    
                    return
                }
                
                let result: Result<T, Error> = self.parse(responseData: data)
                switch result {
                case .success(let parsedResponse):
                    
                    observer.onNext(parsedResponse)
                    
                case .failure(let error):
                    
                    observer.onError(error)
                }
            }
            
            dataTask.resume()
            
            return Disposables.create {
                
                dataTask.cancel()
            }
        })
    }
}
