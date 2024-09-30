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
    case invalidMemoryCache
    case invalidDiskCache
    case imageCreationFailed
    case imageLoadingFailed(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidMemoryCache:
            return "Invalid memory cache"
        case .invalidDiskCache:
            return "Invalid disk cache"
        case .imageCreationFailed:
            return "Image creation failed"
        case .imageLoadingFailed(let error):
            return "Image loading failed: \(error.localizedDescription)"
        }
    }
}
