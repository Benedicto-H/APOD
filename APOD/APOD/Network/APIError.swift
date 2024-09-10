//
//  APIError.swift
//  APOD
//
//  Created by 홍진표 on 9/9/24.
//

import Foundation

// MARK: - 사용자 정의 API Error 타입
enum APIError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case decodingFailure
    case unknown(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .invalidResponse:
            return "The response from the server was unsuccessful."
        case .invalidData:
            return "The data received from the server was invalid."
        case .decodingFailure:
            return "Failed to decode the JSON data."
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}
