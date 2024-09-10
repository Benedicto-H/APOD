//
//  ImageCacheManagerError.swift
//  APOD
//
//  Created by 홍진표 on 9/9/24.
//

import Foundation

// MARK: - 사용자 정의 ImageCacheManager Error 타입

enum ImageCacheManagerError: Error {
    case invalidURL
    case imageCreationFailed
    case dataLoadingFailed(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .imageCreationFailed:
            return "Image creation failed"
        case .dataLoadingFailed(let error):
            return "Data loading failed: \(error.localizedDescription)"
        }
    }
}
