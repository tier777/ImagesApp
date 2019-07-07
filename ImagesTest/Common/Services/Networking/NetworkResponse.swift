//
//  NetworkResponse.swift
//  ImagesTest
//
//  Created by Nikita Gorobets on 07/07/2019.
//  Copyright © 2019 ng. All rights reserved.
//

import Foundation

typealias JSON = [String : Any]

enum NetworkResponseError: Error {
    
    case notFound
    case noContent
    case responseParsingError
    case responseTypeError
    
    var localizedDescription: String {
        
        switch self {
        case .notFound: return "Not found."
        case .noContent: return "No content."
        case .responseParsingError: return "Response parsing error."
        case .responseTypeError: return "Response type error."
        }
    }
}

protocol NetworkResponse {}

extension Data: NetworkResponse {}
extension String: NetworkResponse {}
