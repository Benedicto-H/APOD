//
//  APIError.swift
//  APOD
//
//  Created by 홍진표 on 9/9/24.
//

import Foundation

// MARK: - 사용자 정의 API Error 타입
enum APIError: Error {
    case invalidURL(String)
    case invalidResponse(String)
    case invalidData(String)
}
