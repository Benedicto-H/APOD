//
//  Requestable.swift
//  APOD
//
//  Created by 홍진표 on 11/10/24.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol Requestable {
    
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var queryParams: Encodable? { get }
    var bodyParams: Encodable? { get }
    var headers: [String : String]? { get }
    var sampleData: Data? { get }
}
